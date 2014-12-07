#!/bin/bash
set -e

script_path="`dirname $0`"

mkdir -p "$script_path/obj"
mkdir -p "$script_path/run"
cd "$script_path/obj"

if [ "$(basename "$PWD")" != "obj" ] ; then
    echo "internal error"
    exit 1
fi
rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake

read -p "I am about to guess at your operating system and probably install dependencies.  If you are okay with this, type YES: " yesno

echo
case "$yesno" in 
    [Yy][Ee][Ss])
	echo "Proceeding with installation"
	;;
    *) 
	echo "Aborting installation since answer was not YES"
	exit 1
	;;
esac

case "$(uname)"  in
    Linux)

        case "`hostname`" in
        	godzilla)
        	    cat - <<EOF

It looks like you are on godzilla.  Configuring for godzilla.

At the time this script was written, the software (especially GCC) was
ancient.  Because of this, I will use some software installed in John
Jumper's home directory.  This will clearly become a maintenance
nightmare, so please edit this section of the scipt when godzilla's
Linux distribution is updated.

EOF
 
                    PATH=/home/jumper/toolchains/bin:$PATH \
			HDF5_ROOT=/home/jumper/toolchains \
			cmake ../src \
			-DOLD_DWARF_FORMAT=1 \
		        -DEIGEN3_INCLUDE_DIR=/home/jumper/eigen \
		        -DCMAKE_EXE_LINKER_FLAGS='-Wl,-rpath,/home/jumper/toolchains/lib64'

		    make -j4

		    cat - <<EOF

           ******************************
           ********* IMPORTANT! *********  
           ******************************

Because the software on godzilla is very old (see message above), you
need to use Python libraries in John Jumper's home directory.  On any
command line that runs an upside Python program (e.g.
upside_config.py, extract-vtf.py), you must write 

LD_LIBRARY_PATH=/home/jumper/toolchains/lib:\$LD_LIBRARY_PATH PYTHONPATH=/home/jumper/toolchains/lib/python2.6/site-packages:\$PYTHONPATH 

An example is below:

LD_LIBRARY_PATH=/home/jumper/toolchains/lib:\$LD_LIBRARY_PATH PYTHONPATH=/home/jumper/toolchains/lib/python2.6/site-packages:\$PYTHONPATH ../src/upside_config.py --fasta=foo.fasta --output=bar.h5

EOF
        	    ;;

        	midway*)
		    echo
        	    echo "It looks like you are on midway.  Configuring for midway."
        	    module add python/2.7-2014q3 git cmake gcc hdf5 eigen
        	    easy_install --user numexpr cython cvxopt
        	    easy_install --user tables
        
        	    HDF5_ROOT=$HDF5_DIR cmake ../src
        	    make -j4
        
		    echo
		    echo
        	    echo
        	    echo "Initialization successful"
        	    echo "Please add 'module add git cmake gcc hdf5 python/2.7-2014q3 eigen' to your .bashrc" 
        	    echo
        	    ;;

        	*)
        	    cat - <<EOF
Unknown Linux computer.  If you are on Ubuntu/Debian, you may need to
install using the following command.  If you are not the system
administrator, please point him/her to README.md in this directory.

sudo apt-get install cmake libhdf5-dev libeigen3-dev python-tables python-numpy python-scipy python-cvxopt

Assuming all dependencies are satisfied and beginning installation.
If this fails with an error, just install the dependencies and rerun
this script.

EOF
               cmake ../src
               make -j4
               echo
               echo "Initialization successful"
               ;;
           esac
           ;;

   Darwin)
       cat - <<EOF
It looks like you are on OS X.  You must first install the HomeBrew
package manager (http://brew.sh).  Assuming you have done this
(otherwise rerun the script after installing).

EOF

      brew install homebrew/science/hdf5 cmake eigen
      easy_install --user numexpr cython cvxopt scipy
      easy_install --user tables

      cmake ../src
      make -j4

      echo 
      echo "Installation successful"
      ;;

  *)
      echo "Unknown operating system.  Please see README.md for dependencies.  Good luck!"
      ;;
esac
