#!/bin/bash

# this bit only works on platforms with apt-get, which we probably are, but don't fail if we aren't.  
command -v apt-get >/dev/null 2>&1 || { 
    echo >&2 "I require apt-get but it's not installed."; 
    }
command -v apt-get >/dev/null 2>&1 && {    
    apt-get update
    apt-get install -y build-essential git iputils-ping python2.7 python-pip python2.7-dev
    }
#apt update

#to start with we need solo-open-source-components-1.1.12.tar.gz and 
# a git check of the  sololink_v1.3.0-5 branch from the imx6-linux repo
# into components/ folder.
mkdir components 2>/dev/null  
cd components/
FILE=solo-open-source-components-1.1.12.tar.gz    
if [ -f $FILE ]; then
   echo "File $FILE exists, using cache."
else
   echo "File $FILE does not exist, downloading, please wait....(slow)"
   wget http://solo-open-source.s3-website-us-east-1.amazonaws.com/solo-open-source-components-1.1.12.tar.gz
fi
# do we uncompress all of it? not right now, it's huge - it's also bzip2 compressed, not gzip, despite the name.
#tar -jxvpf ../solo-open-source-components-1.1.12.tar.gz 
FILE=gpl_source_release_1.1.12/GPL-2.0/linux-imx-3.10.17-r0/linux-imx-3.10.17-r0.diff.gz
if [ -f $FILE ]; then
    echo "using already extracted kernel bits as u seem to have them already...."
else
    echo "uncomressing kernel bits from the .tar.gz we just downloaded.....please wait..( slow)"
    tar -jxvpf solo-open-source-components-1.1.12.tar.gz --include='*gpl_source_release_1.1.12/GPL-2.0/linux-imx-3.10.17-r0*'
fi
#' 
cd ..
cd components/
FILE=imx6-linux/README   
if [ -f $FILE ]; then
   echo "kernel git repo appears to exist, using cached repo"
else
   echo "kernel git repo does not exist, downloading, please wait....(slow)"
   git clone http://github.com/3drobotics/imx6-linux
   echo "switching to appropriate branch, please wait...."
   cd imx6-linux && git checkout sololink_v1.3.0-5 && cd -
fi
cd ..

# now we'll prepare sources and patches to build a kernel.
mkdir kernel 2>/dev/null  
cd kernel
#ls ../components/gpl_source_release_1.1.12/GPL-2.0/linux-imx-3.10.17-r0/
#linux-imx-3.10.17-r0-prepatch.tar.gz
#linux-imx-3.10.17-r0-series.tar.gz
#linux-imx-3.10.17-r0.diff.gz
#linux-imx-3.10.17-r0.showdata.dump
# start building in the 'kernel' folder...
cp ../components/gpl_source_release_1.1.12/GPL-2.0/linux-imx-3.10.17-r0/* .
# Extracted all three files. One contained the kernel source, one contained a bunch of patches, one contained a .diff file.
FILE=git/README   
if [ -f $FILE ]; then
   echo "pre-patch kernel directory appears to exist, using on-disk cached repo"
else
   echo "kernel git folder does not exist, extracting, please wait....(slow)"
    tar -zxvpf linux-imx-3.10.17-r0-prepatch.tar.gz 
fi

# smaller gz file we can just redo every time.
tar -zxvpf linux-imx-3.10.17-r0-series.tar.gz 

# as gunzip can be interactive and we want to avoid that: 
FILE=linux-imx-3.10.17-r0.diff   
if [ -f $FILE ]; then
   echo "linux-imx-3.10.17-r0.diff appears to exist, using on-disk cached repo"
else  
    gunzip linux-imx-3.10.17-r0.diff.gz 
fi

# tip: kernel is in 'git'... ie: OpenSolo/kernel/git/ folder.

# Apply the patches and the diff 
#  we want --forward on these patches, so that if they've already been applied, we don't do it twice.
cd linux-imx-3.10.17-r0-series
bunzip2 patch-3.10.17-rt12.patch.bz2
 cp *.patch ../git/
cd ../git
patch -p1 --forward < 0001-dts-changes-to-add-uart5.patch
patch -p1 --forward < 0001-fix-build.patch
patch -p1 --forward < 0002-fix-build-with-rt-enabled.patch
patch -p1 --forward < 0003-no-split-ptlocks.patch
patch -p1 --forward < patch-3.10.17-rt12.patch
patch -p1 --forward < aufs3-base.patch
patch -p1 --forward < aufs3-kbuild.patch
patch -p1 --forward < aufs3-mmap.patch
patch -p1 --forward < aufs3-standalone.patch


# TO BE CONTINUED.... 
echo ""
echo please go read this link if you think u can extend this further....
echo https://discuss.dronekit.io/t/compiling-additional-drivers-for-solo-usb-port/654/ 
echo ""
echo and find the author of this script @davidbuzz at :
echo https://gitter.im/ArduPilot/companion
echo maybe you can figure out what to add below here...
echo 












