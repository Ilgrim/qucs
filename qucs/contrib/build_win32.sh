#!/bin/bash

## file: build_win32.sh
#
## This script cross compiles Qucs from OSX/Linux to Windows 32. It uses Wine and MinGW.

##
# Requires package:     ~/git/qucs/release/qucs-x.x.x.tar.gz
# Extract into:         ~/git/qucs/release/build_win32/qucs-x.x.x
# Setup cross compiler
# Compigure sources
# Compile
# Install binaries into ~/.wine/drive_c/qucs-win32-bin/




## Setup cross-compile environment Mac OS X host, Win32 target

# TODO Linux

## 1) Install Wine (using homebrew)
#
# $ brew install wine

## 2) Install Qt into Wine
#
# Download Qt
#   http://download.qt-project.org/official_releases/qt/4.8/4.8.6/qt-opensource-windows-x86-mingw482-4.8.6.exe.mirrorlist
#
# Install Qt into Wine
# $ wine qt-opensource-windows-x86-mingw482-4.8.6.exe
#
# Follow the installer, note the install
# Install into
#   C:\Qt\4.8.6
#
# It expect MinGW 4.8.2 to be installed, we do it next. Leave the MinGW path as:
#   C:\mingw32


## 3) Install MinGW into Wine (MinGW matched to Qt)
#
# Download MinGW 4.8.3
# http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/4.8.2/threads-posix/dwarf/i686-4.8.2-release-posix-dwarf-rt_v3-rev3.7z
#
# Install (extract) MinGW into Wine
# $ 7z x i686-4.8.2-release-posix-dwarf-rt_v3-rev3.7z -o${HOME}/.wine/drive_c/
#

## 4) Update Wine registry
#
# Either do it manually with: wine regedit
#
# Or pass it as a configuration file
#
# cat > /tmp/qttemp.reg << EOF
# [HKEY_CURRENT_USER\Environment]
# "PATH"="%PATH%;c:\\\windows\\\system32;C:\\\Qt\\\4.8.6\\\bin;C:\\\mingw32\\\bin"
# "QTDIR"="C:\\\Qt\\\4.8.6"
# EOF
# regedit /tmp/qttemp.reg
# rm /tmp/qttemp.reg



## 5) Install Inno Setup 5 (see script `bundle_win32.sh`)
# Install older Inno version due to issues with wine
# Error: * Could not find dependent assembly L"Microsoft.Windows.Common-Controls" (6.0.0.0)
#
# Install http://files.jrsoftware.org/is/5/isetup-5.5.0.exe	29-May-2012 06:51 	1.8M
# $ wine isetup-5.5.0.exe



## Notes:
# Need --disable-dependency-tracking to avoid mixup of host and target header files
# https://software.sandia.gov/trac/acro/ticket/2835


##
# Build Win32 Binary
# * build ASCO
# * build ADMS
# * include freehdl
# * include iverilog
# * link to MinGW (needed for freeHDL and Verilog-A compiler)
# * lint to Octave


# TODO
# * use Travis to package, build binary and upload to SF
#   * create a release/package branches
#   * figure out a way to install silently, no user intervention.
#   * maybe AutoIt can be used
#   * perhaps nightly builds in the future

# extract tarball
# cd into
# configure
# make
# make install

if [ $# -ne 0 ]
then
  RELEASE=$1
else
  RELEASE=$(date +"%y%m%d")
  RELEASE="0.0.18."${RELEASE:0:6}
fi
echo Building release: $RELEASE

REPO=${PWD}
echo Working from: ${REPO}
# TODO test location

cd ${REPO}/release
mkdir build_win32
cd build_win32

# Requires package:     ~/git/qucs/release/qucs-x.x.x.tar.gz
tar xvfz ../qucs-${RELEASE}.tar.gz
cd qucs-${RELEASE}


echo "Building mingw32"


# Temporary install prefix
WINDIR=${HOME}/.wine/drive_c/qucs-win32-bin

# Set QTDIR
export QTDIR=${HOME}/.wine/drive_c/Qt/4.8.6

export AR="wine ar.exe"
export AS="wine as.exe"
export CXX="wine g++.exe"
export CC="wine gcc.exe"
export LD="wine ld.exe"
export DLLTOOL="wine dlltool.exe"
export NM="wine nm.exe"
export OBJDUMP="wine objdump.exe"
export RANLIB="wine ranlib.exe"
export STRIP="wine strip.exe"
export WINDRES="wine windres.exe"

echo "Configuring for i386-MinGW32 cross ..."


./configure --prefix=${WINDIR} --target=i386-mingw32 --host=i386-mingw32 --build=i586-linux --program-prefix="" --disable-dependency-tracking

make -j 8
make install
# Install binaries into ~/.wine/drive_c/qucs-win32-bin/
