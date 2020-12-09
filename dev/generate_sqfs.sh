#!/bin/sh

[ $1 ] || exit 1;
[ -f $1.tcz.list ] || exit 2;
[ -f $1.tcz.info ] || exit 3;

# Clean up any failed runs
rm -Rf $1 $1.tcz
git restore $1.tcz.list

# Prepare staging area
mkdir $1
while read file
do
	DIRNAME=$(dirname $file)
	[ -d "$DIRNAME" ] || mkdir -p $1/$DIRNAME
	ln -v _install/$file $1/$DIRNAME
done < $1.tcz.list

# Pack up into .tcz file
mksquashfs $1 $1.tcz -b 4k -no-xattrs

# Update .info file with size
SIZE=$(du -h $1.tcz | cut -f 1)
sed -i 's/^Size: */&'$SIZE'/' $1.tcz.info

# Create zsync file
zsyncmake $1.tcz >/dev/null 2>&1

# Pack it all up
tar cvfz $1.tar.gz $1.tcz*

# Clean up
rm -Rf $1 $1.tcz $1.tcz.zsync
