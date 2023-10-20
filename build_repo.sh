#!/bin/bash

#compile systemd with the patches and create
#a new debian repo with the generated packages

set -e
if [ "$DEBUG" ]; then
  set -x
fi

supported_releases="bookworm unstable"
base_path="$(realpath $(pwd))"
repo_dir="$base_path/repo/"

rm -rf $repo_dir || true
mkdir -p $repo_dir

for release_name in $supported_releases; do
  cd $base_path

  . ./build.sh $release_name
  pool_dir="$repo_dir/pool/main/$release_name"
  dists_dir="$repo_dir/dists/$release_name/main/binary-amd64"
  
  mkdir -p $dists_dir
  mkdir -p $pool_dir

  cp $base_path/build/*.deb $pool_dir
  cd $repo_dir
  dpkg-scanpackages --arch amd64 pool/main/$release_name > $dists_dir/Packages
  cat $dists_dir/Packages | gzip -9 > $dists_dir/Packages.gz
done

