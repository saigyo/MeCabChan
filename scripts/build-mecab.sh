#!/bin/bash
# Builds a static arm64 libmecab into vendor/mecab (lib/libmecab.a, include/mecab.h)
# and compiles the IPADIC dictionary from the same MeCab repository into vendor/ipadic.
# Skips the build if the outputs for the pinned commit are already present.
set -euo pipefail

# Upstream has no release tags; pin a master commit (version 0.996 plus later fixes).
MECAB_REPO=https://github.com/taku910/mecab.git
MECAB_COMMIT=61b90ba6e669dc2d7d533d4a80d206f3b31d52b1
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="$ROOT/vendor"
PREFIX="$VENDOR/mecab"
DICDIR="$VENDOR/ipadic"
DIC_FILES=(sys.dic unk.dic matrix.bin char.bin dicrc)
STAMP="$VENDOR/.built-$MECAB_COMMIT-arm64-$DEPLOYMENT_TARGET"

outputs_present() {
    [[ -f "$STAMP" && -f "$PREFIX/lib/libmecab.a" && -f "$PREFIX/include/mecab.h" ]] || return 1
    for f in "${DIC_FILES[@]}"; do [[ -f "$DICDIR/$f" ]] || return 1; done
}
if outputs_present; then
    exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "Fetching MeCab $MECAB_COMMIT"
git -C "$WORK" init -q src
git -C "$WORK/src" fetch -q --depth 1 "$MECAB_REPO" "$MECAB_COMMIT"
git -C "$WORK/src" -c advice.detachedHead=false checkout -q FETCH_HEAD

# Xcode exports SDK/arch variables to run-script phases that would confuse configure.
unset SDKROOT ARCHS CC CXX CFLAGS CXXFLAGS LDFLAGS CPPFLAGS
export MACOSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
FLAGS="-O2 -arch arm64 -isysroot $SDK"

cd "$WORK/src/mecab"
# Checkout timestamps are arbitrary; mark the generated autotools files as up to date
# so make does not try to rerun automake/autoconf.
touch aclocal.m4
sleep 1
touch configure config.h.in Makefile.in */Makefile.in
# The bundled config.sub predates arm64 macOS, so present a known triplet for a
# native (non-cross) build; the real target comes from -arch.
./configure \
    --build=x86_64-apple-darwin --host=x86_64-apple-darwin \
    --enable-static --disable-shared --with-charset=utf8 \
    --prefix="$PREFIX" \
    CFLAGS="$FLAGS" CXXFLAGS="$FLAGS -std=c++11 -w" LDFLAGS="-arch arm64" \
    > "$WORK/configure.log" || { cat "$WORK/configure.log"; exit 1; }
make -C src -j"$(sysctl -n hw.ncpu)" libmecab.la mecab-dict-index > "$WORK/make.log" 2>&1 || { tail -50 "$WORK/make.log"; exit 1; }

echo "Compiling IPADIC"
mkdir -p "$WORK/ipadic"
(cd "$WORK/src/mecab-ipadic" && "$WORK/src/mecab/src/mecab-dict-index" -d . -o "$WORK/ipadic" -f EUC-JP -t utf8) \
    > "$WORK/dict.log" 2>&1 || { tail -50 "$WORK/dict.log"; exit 1; }
cp "$WORK/src/mecab-ipadic/dicrc" "$WORK/ipadic/"

rm -rf "$PREFIX" "$DICDIR" "$VENDOR"/.built-*
mkdir -p "$PREFIX/lib" "$PREFIX/include" "$DICDIR"
cp src/.libs/libmecab.a "$PREFIX/lib/"
cp src/mecab.h "$PREFIX/include/"
for f in "${DIC_FILES[@]}"; do cp "$WORK/ipadic/$f" "$DICDIR/"; done
touch "$STAMP"
echo "Built $(lipo -info "$PREFIX/lib/libmecab.a") and IPADIC ($(du -sh "$DICDIR" | cut -f1))"
