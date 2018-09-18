# Singularity container for sPHENIX

Singularity container for sPHENIX allow collaborators to run sPHENIX RCF environment with sPHENIX nightly builds on local computers or external high performance computing centers. 

This repository include the launcher and local update macro for the sPHENIX Singularity container.

# Get Started

1. On your local system, install [Singularity v2.5](https://www.sylabs.io/guides/2.5/user-guide/quick_start.html#installation)

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

4. Enter the Singularity container 

```
singularity shell -B afs:/afs rhic_sl7_ext.simg
source /opt/sphenix/core/bin/sphenix_setup.sh -n   # setup sPHENIX environment in the singularity container shell
```

This bring up a shell environment which is identical to sPHENIX RCF. Meanwhile, it use your local file system for non-system files, e.g. it directly work on your code or data directories. Singularity container also support running in the [command mode or background mode](https://www.sylabs.io/guides/2.5.1/user-guide/quick_start.html#interact-with-images). 

5. Run [the sPHENIX simulation tutorial](https://github.com/sPHENIX-Collaboration/macros)

6. To get daily build update, run the download/update macro [updatebuild.sh](./updatebuild.sh) to sync build files again. 


