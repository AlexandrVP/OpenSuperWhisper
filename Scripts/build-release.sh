#!/bin/bash
# Build a portable Apple Silicon app; never install over the developer's app.
set -euo pipefail
cd "$(dirname "$0")/.."

version="${1:-0.1.1}"
build_number="${BUILD_NUMBER:-14}"
deployment_target="15.0"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ ! "$build_number" =~ ^[0-9]+$ ]]; then
    echo "Usage: BUILD_NUMBER=14 $0 0.1.1" >&2
    exit 1
fi
if [[ "$(uname -m)" != arm64 ]]; then
    echo "Build this release on an Apple Silicon Mac." >&2
    exit 1
fi
xcodebuild -version
for dependency in cmake cargo brew python3; do command -v "$dependency" >/dev/null; done
test -f libwhisper/whisper.cpp/CMakeLists.txt
test -f asian-autocorrect/autocorrect/Cargo.toml
export MACOSX_DEPLOYMENT_TARGET="$deployment_target"
mkdir -p build dist

# M1-compatible instructions, with no detection of the build machine's CPU.
cmake -G Xcode -B libwhisper/build -S libwhisper \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$deployment_target" \
    -DGGML_NATIVE=OFF -DGGML_CPU_ARM_ARCH=armv8.2-a+dotprod+fp16 \
    -DGGML_METAL_EMBED_LIBRARY=ON

CARGO_PROFILE_RELEASE_LTO=true \
CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1 \
CARGO_PROFILE_RELEASE_STRIP=symbols \
CARGO_PROFILE_RELEASE_PANIC=abort \
cargo build --locked --release --target aarch64-apple-darwin \
    --manifest-path libautocorrect/Cargo.toml
cp libautocorrect/target/aarch64-apple-darwin/release/libautocorrect_swift.dylib build/
cp "$(brew --prefix libomp)/lib/libomp.dylib" build/
for library in libautocorrect_swift libomp; do
    chmod u+w "build/$library.dylib"
    install_name_tool -id "@rpath/$library.dylib" "build/$library.dylib"
    codesign --force --sign - --timestamp=none "build/$library.dylib"
done

xcrun swiftc -D FILTER_STANDALONE_TEST \
    OpenSuperWhisper/Utils/WhisperHallucinationFilter.swift \
    OpenSuperWhisperTests/WhisperHallucinationFilterTests.swift \
    -o build/phrase-filter-tests
build/phrase-filter-tests

xcodebuild -project OpenSuperWhisper.xcodeproj -scheme OpenSuperWhisper \
    -configuration Release -destination 'platform=macOS,arch=arm64' \
    -derivedDataPath build -clonedSourcePackagesDirPath SourcePackages \
    -onlyUsePackageVersionsFromResolvedFile \
    -skipPackagePluginValidation -skipMacroValidation \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= \
    DEVELOPMENT_TEAM= ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
    MACOSX_DEPLOYMENT_TARGET="$deployment_target" \
    MARKETING_VERSION="$version" CURRENT_PROJECT_VERSION="$build_number" \
    build

app="build/Build/Products/Release/OpenSuperWhisper.app"
test -x "$app/Contents/MacOS/OpenSuperWhisper"
/usr/libexec/PlistBuddy -c "Set :LSMinimumSystemVersion $deployment_target" "$app/Contents/Info.plist"

# Normalize Homebrew install names before signing; reject anything unbundled.
python3 Scripts/verify-release.py "$app" --prepare
while IFS= read -r -d '' library; do
    codesign --force --sign - --timestamp=none "$library"
done < <(find "$app/Contents" -type f -name '*.dylib' -print0)
codesign --force --sign - --timestamp=none \
    --entitlements OpenSuperWhisper/OpenSuperWhisper.entitlements "$app"
python3 Scripts/verify-release.py "$app"

staging="$(mktemp -d "$PWD/build/release-stage.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
ditto "$app" "$staging/OpenSuperWhisper.app"
cp docs/install.md "$staging/INSTALL.md"
cp LICENSE "$staging/LICENSE.txt"
mkdir -p "$staging/ThirdPartyLicenses"
cp "$(brew --prefix libomp)/LICENSE.TXT" "$staging/ThirdPartyLicenses/libomp-LICENSE.txt"
for dependency in libwhisper/whisper.cpp asian-autocorrect SourcePackages/checkouts/*; do
    if [[ -d "$dependency" ]]; then
        while IFS= read -r -d '' license; do
            cp "$license" "$staging/ThirdPartyLicenses/$(basename "$dependency")-$(basename "$license").txt"
        done < <(find "$dependency" -maxdepth 1 -type f \( -iname 'license*' -o -iname 'copying*' \) -print0)
    fi
done
archive="OpenSuperWhisper-$version-macOS-arm64.zip"
ditto -c -k --sequesterRsrc "$staging" "dist/$archive"
unzip -tq "dist/$archive"
roundtrip="$(mktemp -d "$staging/verify.XXXXXX")"
ditto -x -k "dist/$archive" "$roundtrip"
python3 Scripts/verify-release.py "$roundtrip/OpenSuperWhisper.app"
(cd dist && shasum -a 256 "$archive" > "$archive.sha256")
echo "Release archive: dist/$archive"
