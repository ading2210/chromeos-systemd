#!/bin/bash

set -e
if [ "$DEBUG" ]; then
  set -x
fi

print_help() {
  echo "Usage: ./build.sh release_name [arch]"
  echo "release_name should be either 'bookworm' or 'unstable'"
}

if [ -z "$1" ]; then
  print_help
  exit 1
fi

if [ "$2" ]; then
  arch="$2"
else
  arch="amd64"
fi

release_name="$1"
base_path="$(realpath $(pwd))"
patch_path="${base_path}/systemd_${release_name}.patch"

if [ $release_name = "bookworm" ]; then
  branch_name="debian/bookworm"
elif [ $release_name = "unstable" ]; then
  branch_name="debian/master"
else
  print_help
  exit 1
fi

echo "creating build directory"
rm -rf build || true
mkdir -p build
cd build

echo "cloning systemd repo and applying patches"
git clone "https://salsa.debian.org/systemd-team/systemd" --depth=1 --branch $branch_name
cd systemd
git apply "${patch_path}"

echo "installing deps"
sudo mk-build-deps -i -r -a $arch --host-arch $arch

echo "building debian packages"
dpkg-buildpackage -b -rfakeroot -us -uc -a$arch

echo "build complete"
