#!/bin/bash
# set -x

if [ "$#" -ne "1" ]; then
	echo "Expected 1 argument, got $#" >&2
	usage
	exit 2
fi

if [ $1 = "debug" ]; then
	make_tag=Debug
	make_arguments="CONFIG+=debug"
else
	make_tag=Release
	make_arguments=""
fi
	
	
project_name=${PWD##*/}
project_name_lowercase=quazip
echo ${project_name}
build_path=build-${project_name}-Desktop-${make_tag}

cd ..
mkdir ${build_path}
cd ${build_path}
qmake ../${project_name}/${project_name_lowercase}.pro -r -spec linux-g++ ${make_arguments}
sudo make clean
sudo make -j8 install
