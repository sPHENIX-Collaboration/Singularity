#!/bin/bash

echo "--------------------------------------------------------"
echo "This macro download/update sPHENIX builds to ./cvmfs/sphenix.sdcc.bnl.gov"
echo ""
echo "If you have CVMFS directly mounted on your computer,"
echo "you can skip this download and mount /cvmfs/sphenix.sdcc.bnl.gov to singularity directly."
echo "--------------------------------------------------------"

mkdir -pv cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release

echo "--------------------------------------------------------"
echo "Downloading the sPHENIX container and lib files to cvmfs/sphenix.sdcc.bnl.gov/" 
echo "--------------------------------------------------------"

rsync -aL  --progress rftpexp.rhic.bnl.gov:/cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg cvmfs/sphenix.sdcc.bnl.gov/singularity/

echo "--------------------------------------------------------"
echo "Downloading /afs/rhic.bnl.gov/x8664_sl7/opt/sphenix/"
echo "--------------------------------------------------------"

rsync -al --delete --progress rftpexp.rhic.bnl.gov:/cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/opt cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/ ;

echo "--------------------------------------------------------"
echo "Downloading /afs/rhic.bnl.gov/sphenix/sys/x8664_sl7/new/"
echo "--------------------------------------------------------"

rsync -al --delete --progress rftpexp.rhic.bnl.gov:/cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/new/ cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/new/;

echo "--------------------------------------------------------"
echo "Done! To run the sPHENIX container in shell mode:"
echo ""
echo "singularity shell -B cvmfs:/cvmfs cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg"
echo ""
echo "More on singularity tutorials: https://www.sylabs.io/docs/"
echo "More on directly mounting cvmfs instead of downloading: https://github.com/sPHENIX-Collaboration/singularity"
echo "--------------------------------------------------------"


