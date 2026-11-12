#!/bin/bash
# Exercise the production Parakeet engine with deterministic SDK output.
# Full release compilation still uses the real pinned FluidAudio package.
set -euo pipefail
cd "$(dirname "$0")/.."
check_dir="$(mktemp -d "${TMPDIR:-/tmp}/osw-parakeet-filter.XXXXXX")"
trap 'rm -rf "$check_dir"' EXIT

xcrun swiftc -swift-version 5 -module-cache-path "$check_dir/module-cache" \
    -emit-library -emit-module -module-name FluidAudio \
    Scripts/Tests/ParakeetFilter/FluidAudio.swift \
    -emit-module-path "$check_dir/FluidAudio.swiftmodule" \
    -Xlinker -install_name -Xlinker @rpath/libFluidAudio.dylib \
    -o "$check_dir/libFluidAudio.dylib"

xcrun swiftc -swift-version 5 -module-cache-path "$check_dir/module-cache" \
    -I "$check_dir" -L "$check_dir" -lFluidAudio \
    -Xlinker -rpath -Xlinker "$check_dir" \
    Scripts/Tests/ParakeetFilter/AppSupport.swift \
    OpenSuperWhisper/Engines/TranscriptionEngine.swift \
    OpenSuperWhisper/Engines/FluidAudioEngine.swift \
    OpenSuperWhisper/Utils/WhisperHallucinationFilter.swift \
    Scripts/Tests/ParakeetFilter/Runner.swift \
    -o "$check_dir/parakeet-filter-checks"
"$check_dir/parakeet-filter-checks"
