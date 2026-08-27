#!/usr/bin/env bash
set -euo pipefail

verilator_version="${VERILATOR_VERSION:-5.050}"
expected_version="Verilator ${verilator_version}"

if command -v verilator >/dev/null 2>&1 &&
    verilator --version | grep -Fq "$expected_version"; then
  verilator --version
  exit 0
fi

tool_root="${RUNNER_TEMP:-/tmp/mpsoc-osoc-ci-tools}"
source_dir="$tool_root/verilator-src-$verilator_version"
install_dir="$tool_root/verilator-$verilator_version"

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  autoconf bison flex g++ git help2man libfl-dev liblz4-dev make perl \
  python3 zlib1g-dev

rm -rf "$source_dir" "$install_dir"
git clone --branch "v$verilator_version" --depth 1 \
  https://github.com/verilator/verilator.git "$source_dir"

(
  cd "$source_dir"
  autoconf
  ./configure --prefix="$install_dir"
  make -j"$(nproc)"
  make install
)

"$install_dir/bin/verilator" --version | grep -F "$expected_version"
printf '%s/bin\n' "$install_dir" >> "$GITHUB_PATH"
