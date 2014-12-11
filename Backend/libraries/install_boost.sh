#!/bin/sh
boosturl="http://sourceforge.net/projects/boost/files/boost/1.57.0/boost_1_57_0.tar.bz2/download"
boostdir="boost_1_57_0"
tarball="boost_1_57_0.tar.bz2"
wget "$boosturl" -O "$tarball"
tar -xvjf ${tarball}
inst_dir="boost_install"
mkdir -p "${inst_dir}"
cd ${boostdir}
./bootstrap.sh --with-libraries=iostreams,filesystem,program_options,system,serialization,mpi --prefix=${inst_dir} --with-toolset=gcc 
./bjam install
cd ..

