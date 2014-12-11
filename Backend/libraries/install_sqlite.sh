#!/bin/sh
sqliteurl="http://www.sqlite.org/2014/sqlite-autoconf-3080704.tar.gz"
sqlitedir="sqlite-autoconf-3080704"
tarball="sqlite-autoconf-3080704.tar.gz"
wget "$sqliteurl" -O "$tarball"
tar -xvjf ${tarball}
inst_dir="sqlite_install"
mkdir -p "${inst_dir}"
cd ${sqlitedir}
./configure --prefix="$(dirname `pwd`)/${inst_dir}"
make
make install
cd ..

