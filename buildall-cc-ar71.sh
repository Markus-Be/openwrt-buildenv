#!/bin/bash

# fail on errors
set +e

# create and enter branch directory
branch=chaos_calmer
if [ ! -d $BRANCH ]
then
	mkdir $BRANCH
fi
cd $BRANCH

# build options
REMOTE=git://git.openwrt.org/openwrt.git
TARGET=ar71xx
MAKEOPTS="-j2"

# checkout openwrt repository
if [ ! -d openwrt ]
then
	# install build-env sources
	git clone $REMOTE openwrt
else
	git pull
fi

# enter build-env
cd openwrt

# prepare package feeds
cp feeds.conf.default feeds.conf
echo "src-git luci2 http://git.openwrt.org/project/luci2/ui.git" >> feeds.conf
echo "src-git cjdns git://github.com/seattlemeshnet/meshbox.git" >> feeds.conf
echo "src-git fastd git://git.metameute.de/lff/pkg_fastd" >> feeds.conf
echo "src-git mwan3 git://github.com/Adze1502/mwan.git" >> feeds.conf
echo "src-git batmanadv http://git.open-mesh.org/openwrt-feed-batman-adv.git" >> feeds.conf
echo "src-git wbm git://github.com/battlemesh/battlemesh-packages.git" >> feeds.conf
echo "src-git libreage git://github.com/libremap/libremap-agent-openwrt.git" >> feeds.conf
echo "src-git kadnode git://github.com/mwarning/KadNode.git" >> feeds.conf
echo "src-git kadlibsodium git://github.com/mwarning/libsodium-openwrt.git" >> feeds.conf
echo "src-git fswebcam git://github.com/fsphil/fswebcam.git" >> feeds.conf
echo "src-git solarfestival git://github.com/freifunk-leipzig/solarfestival-packages.git" >> feeds.conf

# create index and install all packages
scripts/feeds update -a
scripts/feeds update -i
scripts/feeds install -a

# create default config for given platform
cat >.config <<EOF
CONFIG_MODULES=y
CONFIG_HAVE_DOT_CONFIG=y
CONFIG_TARGET_${TARGET}=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_ALL=y
CONFIG_IMAGEOPT=y
CONFIG_DEVEL=y
CONFIG_NEED_TOOLCHAIN=y
CONFIG_TOOLCHAINOPTS=y
CONFIG_SSP_SUPPORT=y
CONFIG_IB=y
CONFIG_COLLECT_KERNEL_DEBUG=y
CONFIG_BUILD_PATENTED=y
CONFIG_KERNEL_KALLSYMS=y
CONFIG_KERNEL_DEBUG_KERNEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_PACKAGE_kmod-ath=y
CONFIG_ATH_USER_REGD=y
CONFIG_PACKAGE_ATH_DFS=y
CONFIG_PACKAGE_ATH_DEBUG=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="OpenWrt"
CONFIG_VERSION_NICK=""
CONFIG_VERSION_NUMBER=""
CONFIG_VERSION_REPO="http://openwrt.k4rnet.de/${BRANCH}/packages"
CONFIG_PACKAGE_collectd-mod-netlink=n
CONFIG_PACKAGE_kmod-pcspkr=n
CONFIG_PACKAGE_LUCI=y
CONFIG_PACKAGE_6IN4=y
EOF

# configure default config
make defconfig

# allow stuff to fail from here on
set -e

# paste command
echo "please run following within screen or tmux:"
echo "cd ${BRANCH}/openwrt && make $MAKEOPTS IGNORE_ERRORS=m V=99 BUILD_LOG=1"
