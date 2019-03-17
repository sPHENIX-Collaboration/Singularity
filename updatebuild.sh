#!/bin/bash

build='new';
# build='root6';

URLBase='https://www.phenix.bnl.gov/WWW/publish/phnxbld/sPHENIX/Singularity/';
DownloadBase='cvmfs/sphenix.sdcc.bnl.gov/';

echo "--------------------------------------------------------"
echo "This macro download/update sPHENIX builds to $DownloadBase"
echo ""
echo "If you have CVMFS directly mounted on your computer,"
echo "you can skip this download and mount /cvmfs/sphenix.sdcc.bnl.gov to singularity directly."
echo "--------------------------------------------------------"

mkdir -p cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release

echo "--------------------------------------------------------"
echo "Downloading ${URLBase}/rhic_sl7_ext.simg -> ${DownloadBase}/singularity/ ..."
echo "--------------------------------------------------------"

# rsync -aL  --progress rftpexp.rhic.bnl.gov:/cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg cvmfs/sphenix.sdcc.bnl.gov/singularity/
wget -N --no-check-certificate --directory-prefix=${DownloadBase}/singularity/ ${URLBase}/rhic_sl7_ext.simg

echo "--------------------------------------------------------"
echo "Downloading and decompress ${DownloadBase}/ ${URLBase}/${build}/opt.tar.bz2 "
echo "This might take a while ...."
echo "--------------------------------------------------------"

# rsync -al --delete --progress rftpexp.rhic.bnl.gov:/cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/opt cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/ ;
# https://www.phenix.bnl.gov/phenix/WWW/publish/phnxbld/sPHENIX/Singularity/new/opt.tar.bz2

wget --quiet --no-check-certificate --directory-prefix=${DownloadBase}/ ${URLBase}/${build}/opt.tar.bz2 -O- | tar xjf -  
# Or buffer the tar file
# wget -N --no-check-certificate --directory-prefix=${DownloadBase}/ ${URLBase}/${build}/opt.tar.bz2
# tar xjfv cvmfs/sphenix.sdcc.bnl.gov/opt.tar.bz2  


echo "--------------------------------------------------------"
echo "Downloading and decompress ${DownloadBase}/ ${URLBase}/${build}/offline_main.tar.bz2 "
echo "This might take a while ...."
echo "--------------------------------------------------------"

# rsync -al --delete --progress rftpexp.rhic.bnl.gov:/cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/new/ cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/new/;
# https://www.phenix.bnl.gov/phenix/WWW/publish/phnxbld/sPHENIX/Singularity/new/offline_main.tar.bz2

wget --quiet --no-check-certificate --directory-prefix=${DownloadBase}/ ${URLBase}/${build}/offline_main.tar.bz2 -O- | tar xjf -  

echo "--------------------------------------------------------"
echo "Done! To run the sPHENIX container in shell mode:"
echo ""
echo "singularity shell -B cvmfs:/cvmfs cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg"
echo "source /opt/sphenix/core/bin/sphenix_setup.sh -n $build"
echo ""
echo "More on singularity tutorials: https://www.sylabs.io/docs/"
echo "More on directly mounting cvmfs instead of downloading: https://github.com/sPHENIX-Collaboration/singularity"
echo "--------------------------------------------------------"


