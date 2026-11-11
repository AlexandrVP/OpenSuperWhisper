#!/usr/bin/env python3
"""Fetch the pinned Homebrew ARM64/Sequoia bottle without installing it."""
import hashlib
import json
import sys
import urllib.request
from pathlib import Path

# libomp 23.1.5, arm64_sequoia, from https://formulae.brew.sh/api/formula/libomp.json
SHA256 = "2d0ef3890bcb061641c46bc3e52addc7d85627977a4dcd94938ccbd29774b9f0"
URL = "https://ghcr.io/v2/homebrew/core/libomp/blobs/sha256:" + SHA256
destination = Path(sys.argv[1]).resolve()
if not destination.is_file() or hashlib.sha256(destination.read_bytes()).hexdigest() != SHA256:
    # Anonymous, read-only token for this public Homebrew package; no user secrets.
    request = urllib.request.Request(
        "https://ghcr.io/token?service=ghcr.io&scope=repository:homebrew/core/libomp:pull",
        headers={"User-Agent": "OpenSuperWhisper-release"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        token = json.load(response)["token"]
    request = urllib.request.Request(URL, headers={"Authorization": "Bearer " + token})
    with urllib.request.urlopen(request, timeout=120) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != SHA256:
        raise RuntimeError("Homebrew libomp bottle checksum mismatch")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(data)
print(destination)
