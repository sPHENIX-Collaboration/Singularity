# Singularity container for sPHENIX

Singularity container for sPHENIX allow collaborators to run sPHENIX RCF/SDCC environment with sPHENIX nightly builds on your local computers or on external high-performance computing clusters. 

This repository includes the instruction and local update macro for the sPHENIX Singularity container.

# How to download sPHENIX software

sPHENIX software can be obtained to your local computing environment in two ways: 

1. Option 1, **Mount sPHENIX CVMFS**: sPHENIX container, software and builds are distribute on [https://www.racf.bnl.gov/docs/services/cvmfs/info CVMFS] since Nov 2018. Like RCF/SDCC computing cluster at BNL, external collaborating computing center could also mount the `/cvmfs/sphenix.sdcc.bnl.gov/` CVMFS repository, which automatically obtain, buffer and update all sPHENIX build files.
2. Option 2, **Download sPHENIX build via ssh**: one can also directly download the files for sPHENIX build to a local folder via ssh. 

The advantage of **Mount sPHENIX CVMFS** is that it mounts all sPHENIX builds and software and perform automatic caching and updates. This would be suitable for the case of a computing center or server environment. However, it require network connection to function. Therefore, if you wish to use sPHENIX software on laptop during travel, **Downloading sPHENIX build via ssh** would work best. 

## Option 1: Mount sPHENIX CVMFS

1. On your local system, install [Singularity v2.5](https://www.sylabs.io/guides/2.5/user-guide/quick_start.html#installation). 
*Note: the current RCF image is built under Singularity v2.5.0. Newer version of Singularity may be incompatible to load this image.*

2. Install [CVMFS from CERN](https://cernvm.cern.ch/portal/filesystem/quickstart). CERN support build packages under (various Linux distribution and MAC)[https://cernvm.cern.ch/portal/filesystem/downloads].

3. Copy these three configuration and key files to your local computer from RCF (e.g. from any interactive RCF computer nodes):

```
/etc/cvmfs/keys/sdcc.bnl.gov/sphenix.sdcc.bnl.gov.pub
/etc/cvmfs/config.d/sphenix.sdcc.bnl.gov.local
/etc/cvmfs/domain.d/sdcc.bnl.gov.local
```

   Add `sphenix.sdcc.bnl.gov` to `CVMFS_REPOSITORIES` in `/etc/cvmfs/default.local`. e.g. 
```
CVMFS_REPOSITORIES=sphenix.sdcc.bnl.gov
```
   You may also need to specify `CVMFS_HTTP_PROXY` in `/etc/cvmfs/default.local` from your local computing to access the `http://cvmfs.sdcc.bnl.gov:8000/` server. For direct network access, `CVMFS_HTTP_PROXY=DIRECT` would work. 

   After completing step 2 and 3, please confirm you can read local path `/cvmfs/sphenix.sdcc.bnl.gov/`, which should show same content as that on RCF interactive nodes. 
   
4. launch singularity container for sPHENIX with following command

```
singularity shell -B /cvmfs:/cvmfs /cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg
source /opt/sphenix/core/bin/sphenix_setup.sh -n   # setup sPHENIX environment in the singularity container shell. Note the shell is bash by default
root # give a test
```

## Option 2: Download sPHENIX build via ssh

**Note: this option is still been worked on by confining the RCF `rftpexp` ssh server to mount CVMFS. Following is the expected steps after this ticket is resolved at RCF.**

1. On your local system, install [Singularity v2.5](https://www.sylabs.io/guides/2.5/user-guide/quick_start.html#installation). 
*Note: the current RCF image is built under Singularity v2.5.0. Newer version of Singularity may be incompatible to load this image.*

2. Download this repository:

```
git clone git@github.com:sPHENIX-Collaboration/Singularity.git
cd Singularity/
```

3. Run the download/update macro [updatebuild.sh](./updatebuild.sh).

```
./updatebuild.sh
```

This macro download the current release of sPHENIX Singularity container and nightly build libs. If there is already a download, only updates will be transmitted. 

Currently we use the RCF ```rftpexp``` sftp servers for the download, which will prompt for RCF user password and will be slow (due to number of files). The total download size is about 20 GB. Optimizations with webpage based package download is expected later. 

4. Start the container with 

```
singularity shell -B cvmfs:/cvmfs cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg
source /opt/sphenix/core/bin/sphenix_setup.sh -n   # setup sPHENIX environment in the singularity container shell. Note the shell is bash by default
root # give a test
```

5. To get daily build update, run the download/update macro [updatebuild.sh](./updatebuild.sh) to sync build files again. 


# What's next

After entering the Singularity container, you can source sPHENIX environment and interact with it in the same way as on RCF: 

```
computer:~/> singularity shell <options depending on which of the two downloading options above>
Singularity: Invoking an interactive shell within container...
Singularity rhic_sl7_ext.simg:~/> source /opt/sphenix/core/bin/sphenix_setup.sh -n
Singularity rhic_sl7_ext.simg:~/> lsb_release  -a         # Verify same environment shows up as that on RCF
LSB Version:	:core-4.1-amd64:core-4.1-ia32:core-4.1-noarch
Distributor ID:	Scientific
Description:	Scientific Linux release 7.3 (Nitrogen)
Release:	7.3
Codename:	Nitrogen
```

This bring up a shell environment which is identical to sPHENIX RCF. Meanwhile, it use your local file system for non-system files, e.g. it directly work on your code or data directories. Singularity container also support running in the [command mode or background mode](https://www.sylabs.io/guides/2.5.1/user-guide/quick_start.html#interact-with-images). 

Next, please try [the sPHENIX simulation tutorial](https://github.com/sPHENIX-Collaboration/macros). 
*Note, the container is built for batch computing. It could be tricky to bring up 3D-accelerated graphics for Geant4 display, in particular on MAC.* 

Please discuss on [sPHENIX software email list](https://lists.bnl.gov/mailman/listinfo/sphenix-software-l) and [meeting](https://indico.bnl.gov/categoryDisplay.py?categId=88) regarding any question or suggestion.



