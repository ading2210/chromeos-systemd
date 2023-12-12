#!/bin/bash

set -e
if [ "$DEBUG" ]; then
  set -x
fi

print_help() {
  echo "Usage: ./build.sh release_name [arch]"
  echo "release_name should be either 'bookworm' or 'unstable'"
}

if [ "$EUID" -ne 0 ]; then 
  echo "This script must be run as root"
  exit 1
fi

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

echo "getting current systemd version"
systemd_version="$(apt-cache show systemd | sed -n "s/Version: \(.*\)/\1/p" | tr "~" "_" | head -n 1)"
tag_name="debian/$systemd_version"

echo "cloning systemd repo and applying patches"
git clone "https://salsa.debian.org/systemd-team/systemd"
cd systemd
git reset --hard $tag_name
git apply $patch_path

echo "installing deps"
mk-build-deps -a $arch --host-arch $arch
apt-get install ./*.deb -y

echo "building debian packages"
dpkg-buildpackage -b -rfakeroot -us -uc -a$arch

echo "build complete"
