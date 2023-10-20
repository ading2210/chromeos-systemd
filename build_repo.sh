#!/bin/bash

#compile systemd with the patches and create
#a new debian repo with the generated packages

set -e
if [ "$DEBUG" ]; then
  set -x
fi

supported_releases="bookworm unstable"
base_path="$(realpath $(pwd))"

rm -rf repo || true
mkdir -p repo

for release_name in $supported_releases; do
  cd $base_path

  . ./build.sh $release_name
  pool_dir="$base_path/repo/pool/main/$release_name"
  dists_dir="$base_path/repo/dists/$release_name/main/binary-amd64"
  
  mkdir -p $dists_dir
  mkdir -p $pool_dir

  cp $base_path/build/*.deb $pool_dir
  dpkg-scanpackages --arch amd64 $pool_dir > $dists_dir/Packages
  cat $dists_dir/Packages | gzip -9 > $dists_dir/Packages.gz
done

