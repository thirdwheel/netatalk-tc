#!/bin/sh -e

NEEDED=
DESTDIR=$PWD/_install

# Compiler flags

case $(uname -m) in
	x86) export CFLAGS="-march=i486 -mtune=i486 -Os -pipe"
	     export CXXFLAGS="-march=i486 -mtune=i486 -Os -pipe"
	     export LDFLAGS="-Wl,-O1"
	     ;;
	x86_64) export CFLAGS="-mtune=generic -Os -pipe"
		export CXXFLAGS="-mtune=generic -Os -pipe"
		export LDFLAGS="-Wl,-O1"
		;;
esac

for i in compiletc libgcrypt-dev db-dev squashfs-tools zsync libevent-dev
do
	if [ ! -f /usr/local/tce.installed/$i ]
	then
		NEEDED="$NEEDED $i"
	fi
done

if [ "$NEEDED" ]
then
	tce-load -wi $NEEDED
fi

wget "https://prdownloads.sourceforge.net/netatalk/netatalk-3.1.12.tar.gz?download" -O netatalk-3.1.12.tar.gz

tar -xvf netatalk-3.1.12.tar.gz
cd netatalk-3.1.12

patch -Np0 < ../netatalk-3.1.12-dircache.patch

./configure --prefix=/usr/local --disable-quota --without-libevent
make
sudo make DESTDIR=$DESTDIR install

for i in $DESTDIR/usr/local/etc/*.conf
do
	sudo mv "$i" "$i.dist"
done

cd ..
for i in "" -dev -doc
do
	dev/generate_sqfs.sh netatalk$i
done
