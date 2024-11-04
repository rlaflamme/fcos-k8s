#!/usr/bin/sh


FCOS_VERSION=40.20240728.3.0

remove_ssh_key()
{
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$1" 2> /dev/null
}

remove_ssh_keys()
{
  echo "Removing ssh known hosts..."

  remove_ssh_key "$(dig + short okd4-control-plane-1)"
  remove_ssh_key "$(dig + short okd4-control-plane-2)"
  remove_ssh_key "$(dig + short okd4-worker-1)"
  remove_ssh_key "$(dig + short okd4-worker-2)"
  remove_ssh_key "$(dig + short okd4-worker-3)"

  remove_ssh_key "okd4-control-plane-1"
  remove_ssh_key "okd4-control-plane-2"
  remove_ssh_key "okd4-control-plane-3"
  remove_ssh_key "okd4-worker-1"
  remove_ssh_key "okd4-worker-2"
  remove_ssh_key "okd4-worker-3"
}

coreos_installer()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	        quay.io/coreos/coreos-installer:release "$@"
}

butane()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	        quay.io/coreos/butane:release "$@"
}

download_iso()
{
  pushd . ; cd $RELEASE_DIR
  rm -f *.iso
  wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-live.x86_64.iso
  popd
}


download_xz()
{
  pushd . ; cd "$1"
  rm -f fcos.raw.xz fcos.raw.xz.sig
  wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-metal.x86_64.raw.xz
  wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-metal.x86_64.raw.xz.sig

  ln -s fedora-coreos-*-metal.x86_64.raw.xz fcos.raw.xz
  ln -s fedora-coreos-*-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
  popd
}

set -e

#remove_ssh_keys


set -x

INSTALL_DIR=install_dir
OKD4_DIR=/var/www/html/okd4
RELEASE_DIR=release
ISO_DEST_DIR=/var/lib/vz/template/iso

echo "Removing install,iso,release directories"
rm -rf $INSTALL_DIR $RELEASE_DIR

echo "Create install,iso,release directories"
mkdir -p $INSTALL_DIR $RELEASE_DIR $ISO_DEST_DIR

echo "Download iso file"
download_iso $RELEASE_DIR

echo "Create ignition files"
rm -f install-{master,worker}.ign
butane ignition/master.bu -o ignition/master.ign
butane ignition/worker.bu -o ignition/worker.ign

coreos_installer iso ignition embed -i ignition/master.ign    $RELEASE_DIR/fedora-coreos-*-live.x86_64.iso -o $RELEASE_DIR/fcos-master.iso
coreos_installer iso ignition embed -i ignition/worker.ign    $RELEASE_DIR/fedora-coreos-*-live.x86_64.iso -o $RELEASE_DIR/fcos-worker.iso

sudo chown $USER $RELEASE_DIR/*

echo "Copying apache files"
sudo rm -rf $OKD4_DIR/*
sudo cp ./ignition/{master,worker}.ign $OKD4_DIR
sudo cp ./okd-addons/certs/pfsense-lab-okd-{root,intermediate}-ca.crt $OKD4_DIR
sudo chown -R apache. $OKD4_DIR
sudo chmod -R 755 $OKD4_DIR

echo "Publish iso to proxmox nodes"
scp $RELEASE_DIR/*.iso proxmox2.lan:$ISO_DEST_DIR/.

remove_ssh_keys

echo ""
