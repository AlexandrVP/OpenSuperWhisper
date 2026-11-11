# ZIP releases for this fork

`.github/workflows/build.yml` builds and validates an Apple Silicon Release ZIP
on every branch push and pull request. GitHub Actions must be enabled on the fork.
The workflow cross-compiles on macOS 15 Intel with Xcode 26.2 (Swift 6.2), the committed Swift
package pins, Cargo.lock and recursive submodules. No Apple or GitHub personal
access tokens are required: only the publishing job gets `contents: write` via
the short-lived `GITHUB_TOKEN` provided by GitHub Actions.

## Publish

After the branch build succeeds, commit/merge the intended changes into `develop`,
then push a new version tag on that commit:

```sh
git switch develop
git pull --ff-only
git tag -a v0.1.2 -m 'OpenSuperWhisper 0.1.2'
git push origin v0.1.2
```

Tags must be `vMAJOR.MINOR.PATCH`. Update `docs/release-notes.md` before tagging.
The workflow builds from the tag, runs the filter checks, verifies architecture,
minimum OS, embedded libraries and signature, tests ZIP extraction, uploads the
ZIP and SHA-256 checksum to a draft, then publishes it. Failures stop publication.
Re-running a completed release keeps the existing public assets unchanged.
Branch/PR builds only upload Actions artifacts, retained for 14 days.

Download link for users:
https://github.com/AlexandrVP/OpenSuperWhisper/releases/latest

## Build locally

Requires a Mac, full Xcode 26.2 or newer, Homebrew, Rust with the
`aarch64-apple-darwin` target, and initialized submodules. The script fetches the
pinned Homebrew ARM64/macOS 15 libomp bottle (with SHA-256 verification) on either host
architecture; it does not install that bottle. All bundled Mach-O deployment
targets are checked. With rustup, run `rustup target add aarch64-apple-darwin`.
Filter tests run on the host architecture. The app launch smoke test runs only
on ARM64 hosts; an Intel build requires a separate installation/launch check on
Apple Silicon before claiming runtime verification.

```sh
git submodule update --init --recursive
brew install cmake libomp rust
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  BUILD_NUMBER=14 bash Scripts/build-release.sh 0.1.1
```

Output: `dist/OpenSuperWhisper-0.1.1-macOS-arm64.zip` and `.zip.sha256`.
The script never replaces the installed application or copies user data/models.
The binary uses M1-compatible ARM instructions, not the build machine's native
CPU flags. Metal remains enabled. The minimum supported OS is macOS 15.

## Signing

Releases use ad-hoc signatures. They are **not** signed with Apple Developer ID
and are **not** notarized. Users may need “Open Anyway” and may need to re-grant
Accessibility/Input Monitoring after updates. See [installation](install.md).
Developer ID signing and notarization can be added when a certificate and Apple
notarization credentials are available. The upstream `notarize_app.sh` and
`make_release.sh` use the upstream author's identifiers and are not used by this
fork's ZIP workflow.
