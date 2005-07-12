#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/archivista/build_image.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

. $base/misc/target/functions.in

set -e

rm -f $isofsdir/live.squash
mkdir -p $imagelocation ; cd $imagelocation

echo "Preparing root filesystem image from build result ..."

pkg_skip=" ccache distcc "

for pkg in `grep '^X ' $base/config/$config/packages | cut -d ' ' -f 5`; do
	# include the package?
	if [ "${pkg_skip/ $pkg /}" == "$pkg_skip" ] ; then
		cut -d ' ' -f 2 $build_root/var/adm/flists/$pkg >> tar.input
	fi
done

echo "Copying files into the freshly prepared tree ..."
# we need to ignore the errors for now, since the flist have a few files
# that do not exist - TODO: track why
rsync -a --ignore-errors --delete --files-from $PWD/tar.input \
      $build_root $imagelocation || true
rm tar.input

echo "Preparing root filesystem image from target defined files ..."
copy_from_source $base/target/$target/rootfs .

echo "Running ldconfig ..."
chroot . /sbin/ldconfig

du -sh .
echo "Squashing root file-system (this may take some time) ..."
mksquashfs . $isofsdir/live.squash
du -sh $isofsdir/live.squash

