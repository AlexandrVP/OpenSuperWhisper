#!/usr/bin/env python3
"""Reject broken, host-dependent or incorrectly labelled macOS release bundles."""
import argparse
import plistlib
import re
import subprocess
from pathlib import Path


def output(*args):
    return subprocess.check_output(args, text=True).strip()


def version(value):
    parts = tuple(map(int, value.split(".")))
    return parts + (0,) * (3 - len(parts))


def verify(app, prepare=False):
    contents = app / "Contents"
    info = plistlib.loads((contents / "Info.plist").read_bytes())
    minimum = version(info["LSMinimumSystemVersion"])
    executable = contents / "MacOS" / info["CFBundleExecutable"]
    if not executable.is_file():
        raise RuntimeError("Missing application executable")
    for key in ("NSMicrophoneUsageDescription", "NSAccessibilityUsageDescription"):
        if not info.get(key):
            raise RuntimeError(f"Missing {key}")
    if not (contents / "Resources" / "ggml-silero-v5.1.2.bin").is_file():
        raise RuntimeError("Missing bundled voice-activity detection model")
    frameworks = contents / "Frameworks"
    binaries = []
    for path in sorted(contents.rglob("*")):
        if path.is_file() and not path.is_symlink() and "Mach-O" in output("file", "-b", str(path)):
            binaries.append(path)
    for path in binaries:
        if output("lipo", "-archs", str(path)) != "arm64":
            raise RuntimeError(f"Unexpected architecture: {path}")
        loads = output("otool", "-l", str(path))
        # Match only the version-min command, not unrelated load-command versions.
        targets = re.findall(r"\bminos (\d+\.\d+(?:\.\d+)?)", loads) or re.findall(
            r"cmd LC_VERSION_MIN_MACOSX\s+cmdsize \d+\s+version (\S+)", loads
        )
        if not targets or any(version(t) > minimum for t in targets):
            raise RuntimeError(f"{path.name} requires {targets}, app advertises {info['LSMinimumSystemVersion']}")
        for line in output("otool", "-L", str(path)).splitlines()[1:]:
            dependency = line.strip().split(" (", 1)[0]
            if dependency.startswith(("/usr/lib/", "/System/Library/")):
                continue
            if dependency.startswith(("/opt/homebrew/", "/usr/local/")) and prepare:
                bundled = frameworks / Path(dependency).name
                if not bundled.is_file():
                    raise RuntimeError(f"Unbundled dependency: {dependency}")
                subprocess.run(["install_name_tool", "-change", dependency,
                                "@rpath/" + bundled.name, str(path)], check=True)
                continue
            if dependency.startswith("@rpath/"):
                resolved = frameworks / dependency.removeprefix("@rpath/")
                if dependency.startswith("@rpath/libswift"):
                    # Apple ships the Swift runtime with the supported OS.
                    continue
            elif dependency.startswith("@loader_path/"):
                resolved = path.parent / dependency.removeprefix("@loader_path/")
            elif dependency.startswith("@executable_path/"):
                resolved = executable.parent / dependency.removeprefix("@executable_path/")
            else:
                raise RuntimeError(f"External dependency in {path.name}: {dependency}")
            if not resolved.is_file() or not resolved.resolve().is_relative_to(contents.resolve()):
                raise RuntimeError(f"Missing/escaping dependency in {path.name}: {dependency}")
    if not prepare:
        subprocess.run(["codesign", "--verify", "--deep", "--strict", "--verbose=2", str(app)], check=True)
    print(f"Verified {len(binaries)} arm64 binaries, macOS {info['LSMinimumSystemVersion']}+, version {info['CFBundleShortVersionString']}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path)
    parser.add_argument("--prepare", action="store_true")
    args = parser.parse_args()
    verify(args.app.resolve(), args.prepare)
