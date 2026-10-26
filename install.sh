#!/bin/bash
# NeNe Poker installer: downloads the latest release (or NENE_POKER_VERSION), verifies it against SHA256SUMS, then installs it.
#
#   curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-poker/main/install.sh | bash
#
# Installs into ~/.local/bin (override with NENE_POKER_PREFIX). If verification fails, nothing is installed.
set -euo pipefail

repo="hideyukiMORI/nene-poker"
prefix="${NENE_POKER_PREFIX:-$HOME/.local/bin}"

fail() {
    echo "nene-poker install: $1" >&2
    exit 1
}

[ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "x86_64" ] || fail "only Linux on x86_64 is supported (this is $(uname -s) $(uname -m))"
for tool in curl sha256sum tar install; do
    command -v "$tool" > /dev/null || fail "$tool is required"
done

version="${NENE_POKER_VERSION:-}"
if [ -z "$version" ]; then
    latest="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")"
    version="${latest##*/v}"
fi
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "could not determine the version: $version"

name="nene-poker-$version-linux-x86_64"
base="https://github.com/$repo/releases/download/v$version"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "nene-poker install: downloading v$version"
curl -fsSL -o "$work/$name.tar.gz" "$base/$name.tar.gz"
curl -fsSL -o "$work/SHA256SUMS" "$base/SHA256SUMS"
(cd "$work" && sha256sum --check --quiet SHA256SUMS) || fail "checksum does not match SHA256SUMS; nothing was installed"
tar -xzf "$work/$name.tar.gz" -C "$work"
install -Dm755 "$work/$name/nene-poker" "$prefix/nene-poker"

echo "nene-poker install: installed $prefix/nene-poker ($("$prefix/nene-poker" --version))"
case ":$PATH:" in
    *":$prefix:"*) echo "nene-poker install: run nene-poker (q quits, t switches themes, v shows or hides the other players' cards)" ;;
    *) echo "nene-poker install: $prefix is not on your PATH; open a new terminal or run export PATH=\"$prefix:\$PATH\"" ;;
esac
