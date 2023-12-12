#!/bin/bash

set -e
if [ "$DEBUG" ]; then
  set -x
fi

check_args() {
  if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root."
    exit 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: ./build_chroot.sh release_name [arch]"
    echo "release_name should be either 'bookworm' or 'unstable'"
    exit 1
  fi
}

setup_mounts() {
  local target="$1"
  mount -t proc proc $target/proc
  mount -t sysfs sys $target/sys
  mount -o bind /dev $target/dev
  mount -o bind /run $target/run
}

cleanup_mounts() {
  local target="$1"
  local mounts="proc sys dev run"
  for mount in $mounts; do
    if [ -e "$target/$mount" ]; then
      umount -l $target/$mount
    fi
  done
}

check_args "$@"
release_name="$1"
if [ "$2" ]; then
  arch="$2"
else
  arch="amd64"
fi

base_path="$(realpath $(pwd))"
chroot_dir="${base_path}/build/${release_name}/${arch}"

if [ ! -d "$chroot_dir" ]; then
  mkdir -p $chroot_dir
  debootstrap --arch $arch $release_name $chroot_dir https://deb.debian.org/debian
fi

#script that runs in the chroot
cat > $chroot_dir/opt/run.sh << END 
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get install build-essential devscripts git dpkg-dev -y
cd /opt/
. ./build.sh "$@"
END
chmod +x $chroot_dir/opt/run.sh
cp $base_path/build.sh $chroot_dir/opt/build.sh
cp $base_path/systemd_bookworm.patch $chroot_dir/opt/systemd_bookworm.patch
cp $base_path/systemd_unstable.patch $chroot_dir/opt/systemd_unstable.patch


trap "cleanup_mounts $chroot_dir" EXIT
setup_mounts $chroot_dir
chroot $chroot_dir /opt/run.sh $release_name $arch
cleanup_mounts $chroot_dirl
