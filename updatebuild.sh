#!/bin/bash

echo "Downloading the sPHENIX container and lib files to the current folder: $PWD" 

rsync -aLv  --info=progress2 rftpexp.rhic.bnl.gov:/phenix/u/jinhuang/links/sPHENIX_work/Singularity/rhic_sl7_ext.simg ./

echo "--------------------------------------------------------"
echo "Downloading /afs/rhic.bnl.gov/x8664_sl7/opt/sphenix/"
echo "--------------------------------------------------------"

mkdir -pv afs/rhic.bnl.gov/x8664_sl7/opt/sphenix/
rsync -al --delete --info=progress2 rftpexp.rhic.bnl.gov:/afs/rhic.bnl.gov/x8664_sl7/opt/sphenix/ afs/rhic.bnl.gov/x8664_sl7/opt/sphenix/ ;

echo "--------------------------------------------------------"
echo "Downloading /afs/rhic.bnl.gov/sphenix/sys/x8664_sl7/new/"
echo "--------------------------------------------------------"

mkdir -pv afs/rhic.bnl.gov/sphenix/sys/x8664_sl7/
rsync -al --delete --info=progress2 rftpexp.rhic.bnl.gov:/afs/rhic.bnl.gov/sphenix/sys/x8664_sl7/new/ afs/rhic.bnl.gov/sphenix/sys/x8664_sl7/new/ ;

if [ ! -d afs/rhic.bnl.gov/sphenix/new ]; then
    ln -svfb sys/x8664_sl7/new afs/rhic.bnl.gov/sphenix/new
fi

echo "--------------------------------------------------------"
echo "Done! To run the sPHENIX container in shell mode:"
echo ""
echo "singularity shell -B afs:/afs rhic_sl7_ext.simg"
echo ""
echo "More on singularity tutorials: https://www.sylabs.io/docs/"
echo "--------------------------------------------------------"


