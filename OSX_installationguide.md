# Installation Guide for sPHENIX-EIC Standalone Software

### Introduction

Singularity runs under linux OS. But in macOS, it require another layer of virtual machine to generate a linux environment first ([read more on Singularity docs](https://www.sylabs.io/guides/2.5/user-guide/quick_start.html#installation)). The easiest approach would be using the container [within a Unbuntu VirtualBox](VirtualBox.md). 

Alternatively, Here is three steps to the software installation using `vagrant`:

	1. Install necessary virtual machine software on
	   your local computer (OSX or windows) 
	2. Boot up the virtual machine (VM) with some 
	   specifications
	3. Install sPHENIX-EIC software in the VM

	
I'll go through each of these steps, with appropriate links. Note that there are two useful documents which I used to help me install things:

1. [sPHENIX github repo](https://github.com/sPHENIX-Collaboration/singularity)

2. [John Haggerty's instructions on enabling 3D graphics](https://indico.bnl.gov/event/4046/contributions/25558/attachments/21219/28796/singularity_mac_haggerty_20181217.pdf)



## Step 1: Install VM Software



The first step is to install the necessary VM software. This means installing VirtualBox and Vagrant, where VirtualBox is the actual VM software and Vagrant being the tool to build and manage the VM environment. Again, note that these instructions will be for OSX, but the links below should also contain similar instructions for downloading the necessary software on Windows.

##### Relevant, potentially helpful links

[Vagrant installation](https://www.sylabs.io/guides/2.5/user-guide/installation.html#)


#### Installation Procedure

If you don't have [homebrew](https://brew.sh/) installed already, download and install it in your terminal with

```
MacBook-Pro-145:~ Joe$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Once homebrew is installed, you can download and install the necessary software packages

```
MacBook-Pro-145:~ Joe$ brew cask install virtualbox
MacBook-Pro-145:~ Joe$ brew cask install vagrant
MacBook-Pro-145:~ Joe$ brew cask install vagrant-manager
```

Okay, so now you have the necessary software installed on your local computer. To learn more about Vagrant, you can go to their "FAQ" [website](https://www.vagrantup.com/intro/index.html). Time to boot up the VM

```
MacBook-Pro-145:~ Joe$ mkdir singularity-vm
MacBook-Pro-145:~ Joe$ cd singularity-vm
```

Run a `vagrant destroy` to make sure you don't inadvertently have another machine already running. Now boot it up:

```
MacBook-Pro-145:~ Joe$ vagrant init singularityware/singularity-2.4
MacBook-Pro-145:~ Joe$ vagrant up
MacBook-Pro-145:~ Joe$ vagrant ssh
```

Note that this isn't where you need Singularity v2.5.0, as in Jin's tutorial. That comes at a later stage. If you replace the 2.4 above with a 2.5, it won't work. Now you should be ssh-ed in a VM in which you can download Singularity v2.5.0, the necessary sPHENIX software, and get ready to run simulations.




Now its time to get the necessary software on the VM. Execute:

```
vagrant@vagrant:~$ sudo apt-get update && \
  		   sudo apt-get install \
   		   python \
    		   dh-autoreconf \
  		   build-essential \
  		   libarchive-dev
```

This is the equivalent of homebrew on the linux VM that you are logged into, and will get you the necessary packages to install Singularity v2.5.0. Notice that this, and the following, should be performed in the directory `/vagrant`. This directory is shared with your host machine, so it has enough disk space to actually get all of the code etc. Now, somewhat ironically, you are ready for the ["Singularity quick start guide"](https://www.sylabs.io/guides/2.5/user-guide/quick_start.html) to download onto the VM:

```
vagrant@vagrant:~$ git clone https://github.com/sylabs/singularity.git
vagrant@vagrant:~$ cd singularity
vagrant@vagrant:~$ git fetch --all
vagrant@vagrant:~$ git checkout 2.5.0
vagrant@vagrant:~$ ./autogen.sh
vagrant@vagrant:~$ ./configure --prefix=/usr/local
vagrant@vagrant:~$ make
vagrant@vagrant:~$ sudo make install
```

If you have issues with git connecting to the VM, that is just because you haven't uploaded a public/private key pair to your git account that associates it with this computer. See [this link](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to learn how to generate a key. You can upload it into github by going to your account, clicking "settings" and then going to the "SSH and GPG keys" tab on the left. Add the key you just generated in the VM, for which the path was defined when you actually created the key pair.




Now you actually have Singularity v2.5.0 installed on the VM. Time to reboot it back up with some sPHENIX specific settings. Type

```
vagrant@vagrant:~$ exit
```

to go back to your local laptop. 

##### Note for Windows users
 Up to this point, there are probably specific windows instructions that can be found on the  Singularity website for how to get the VirtualBox and Vagrant like software up and running on Windows. The directions above are for OSX users; however, the directions below should apply to any user once they have the VM setup configured as above. The rest of the instructions really only involve the VM - so assuming you can log into the VM the following instructions should (in principle) be helpful.
 
##### Note for Linux users

In principle, one does not need a VM if you are a linux user and you can just directly clone the singularity package from git and install it on your own computer after installing the necessary packages using sudo apt-get. However, I don't know this for sure, and haven't tested it myself - thus I can't comment on the validity of the above statement. This is just my gut feeling.




## Step 2: Setup the VM to handle sPHENIX simulations

sPHENIX simulations require a good deal of memory to be able to run. Just to build the CEMC and MVTX detectors requires a couple of GB of memory. Therefore, you need to setup your VM to have access to the additional RAM in your laptop.

When you booted up the VM for the first time, it should have created a file called `Vagrantfile` in your directory. Open it up in your favorite text editor:

```
emacs Vagrantfile
```

All of the settings that you give the VM to operate are set in this file. Vagrant is written in the langauge Ruby, so a # is a comment. You should notice that most of this file is commented out. There are some additional configurable items that you can learn about [here](https://www.vagrantup.com/docs/virtualbox/configuration.html). I didn't touch any of these and only changed the following.

Find the commented out bit that looks like 

```
  
   #config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     #vb.gui = true

     # Customize the amount of memory on the VM:
     #vb.memory = "1024"
   end
```

Uncomment the `config.vm.provider` line and the `vb.memory` line. These set the memory limits for your VM. You should change the number 1024 to whatever you like - keep in mind that this will set the memory limit of your VM and thus may limit the RAM capability of your own personal laptop. In other words, don't divert all of your RAM to the VM. My laptop has 8 GB of RAM, so I set mine to 4096, like

```
  #
   config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     #vb.gui = true

     # Customize the amount of memory on the VM:
     vb.memory = "4096"
   end
```
   
Now you need to reset your VM setup so that it accepts the new Vagrantfile. Execute:

```
MacBook-Pro-145:singularity-vm Joe$ vagrant reload
MacBook-Pro-145:singularity-vm Joe$ vagrant up
MacBook-Pro-145:singularity-vm Joe$ vagrant ssh
```

Now you are back in the VM, and should have the necessary tools to actually go and download the sPHENIX framework and run simulations.



## Step 3: Install sPHENIX software in the VM


Now you can get the sPHENIX software, which basically follows Jin's instructions from the original [github](https://github.com/sPHENIX-Collaboration/singularity) README.md page.


```
vagrant@vagrant:~$ git clone git@github.com:sPHENIX-Collaboration/Singularity.git
vagrant@vagrant:~$ cd Singularity/
```
Run the download/update script which gets the latest build libraries from the sPHENIX repo. If this is your first time running it, it will take a while (10-20 min) as it downloads about 10 GB of stuff to the VM

```
./updatebuild.sh
```

Now start a singularity container, which will actually be the place where you can get the sPHENIX environment:

```
vagrant@vagrant:~$ singularity shell -B cvmfs:/cvmfs cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg
```

Run the sPHENIX setup script, and you should be in business

```
Singularity rhic_sl7_ext.simg:~/Singularity> source /opt/sphenix/core/bin/sphenix_setup.sh -n
```



Now you can download e.g. the git macros repo and run some simulations. If you are doing this on your local laptop, you will likely be limited by memory consumption (e.g. I only have 8GB RAM total to disperse between my own laptop and the VM running the simulations, which can be memory heavy). 4 GB of RAM should cover most sPHENIX simulations; events with HIJING embedding can be substantially larger, though.

```
Singularity rhic_sl7_ext.simg:~/Singularity> mkdir git
Singularity rhic_sl7_ext.simg:~/Singularity> cd git
Singularity rhic_sl7_ext.simg:~/Singularity> git clone git@github.com:sPHENIX-Collaboration/macros.git
Singularity rhic_sl7_ext.simg:~/Singularity> cd macros/macros/g4simulations/
Singularity rhic_sl7_ext.simg:~/Singularity> root -b -l Fun4All_G4_sPHENIX.C
```


## Tips and Tricks
 * Note that you must stay underneath the /Singularity directory in order to access the libraries. All of the libraries get downloaded into the /cvmfs directory. So my suggestion is to create a directory called /git within Singularity, in which you store all of your code from git (e.g. macros, analysis, coresoftware, etc.).
 * You can run the software offline! No internet connection needed.
 * To enable X11 forwarding so that you can actually take a look at rootfiles that you create, you need to do a few more things. Note that the following assumes you already have XQuartz installed. I found a solution at the following [link](https://computingforgeeks.com/how-to-enable-and-use-ssh-x11-forwarding-on-vagrant-instances/) - instructions copied here:
 	* On the vagrant machine run `vagrant@vagrant:~$ sudo apt-get install xauth`
 	* Return back to your local computer by typing `vagrant@vagrant:~$ exit`
 	* Stop vagrant `MacBook-Pro-145:singularity-vm Joe$ vagrant halt`
 	* Open the Vagrantfile
 	* Add `config.ssh.forward_agent = true` and `config.ssh.forward_x11 = true` after the `config.vm.box="blah"` line	
 	* Boot vagrant back up by executing `vagrant up` and `vagrant ssh`
 	* Log back into the Singularity container with the `singularity shell` command 
 	* I was able to run `xclock &` at the terminal and e.g. open a `TBrowser` in ROOT after this to poke around the TTrees. 
	


## Troubleshooting



I would suggest troubleshooting the nominal way, of e.g. checking Google or other wiki pages, for example the ones that have been linked previously in this document. One problem I ran into when trying this was due to the memory limit/consumption of my virtual machine. Initially, my VM was limited to 1 GB RAM. When I tried running the default Fun4All macro, I would get errors like 

```
cling::DynamicLibraryManager::loadLibrary(): libLHAPDF.so.0: cannot map zero-fill pages: Cannot allocate memory
cling::DynamicLibraryManager::loadLibrary(): /usr/lib64/libgobject-2.0.so.0: undefined symbol: g_date_time_unref
cling::DynamicLibraryManager::loadLibrary(): /usr/lib64/libgobject-2.0.so.0: undefined symbol: g_io_channel_unref
cling::DynamicLibraryManager::loadLibrary(): /usr/lib64/libgobject-2.0.so.0: undefined symbol: g_date_time_unref
cling::DynamicLibraryManager::loadLibrary(): libLHAPDF.so.0: cannot map zero-fill pages: Cannot allocate memory
cling::DynamicLibraryManager::loadLibrary(): libLHAPDF.so.0: cannot map zero-fill pages: Cannot allocate memory
...
```
and so on and so forth, eventually leading to a segmentation fault. You can check your memory limit by running the following

```
Singularity rhic_sl7_ext.simg:~/Singularity> cat /proc/meminfo 
MemTotal:        4046540 kB
MemFree:         3807168 kB
MemAvailable:    3768928 kB
Buffers:           20928 kB
Cached:           132300 kB
SwapCached:            0 kB
Active:            98548 kB
Inactive:          82000 kB
Active(anon):      30232 kB
Inactive(anon):     5572 kB
Active(file):      68316 kB
Inactive(file):    76428 kB
Unevictable:        3660 kB
Mlocked:            3660 kB
SwapTotal:       1048572 kB
SwapFree:        1048572 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         31044 kB
Mapped:            36300 kB
Shmem:              6012 kB
Slab:              29860 kB
SReclaimable:      16092 kB
SUnreclaim:        13768 kB
KernelStack:        2096 kB
PageTables:         2552 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     3071840 kB
Committed_AS:     222544 kB
VmallocTotal:   34359738367 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HardwareCorrupted:     0 kB
AnonHugePages:      8192 kB
CmaTotal:              0 kB
CmaFree:               0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       59328 kB
DirectMap2M:     4134912 kB


```



One can see that my total memory is about 4GB - exactly what I have had it set to in my Vagrantfile on my local laptop. Should you change the memory limit in your vagrant file and perform a

```
vagrant reload 
vagrant up 
vagrant ssh
```

you should see this memory limit reflected with this command and/or the `top` shell command.




One can also check that the necessary libraries are in the correct place by running (after running the sphenix environment script), which should print out many of the libraries for e.g. g4detectors and soft link pointers to where the libraries exist in your downloaded code.

```
Singularity rhic_sl7_ext.simg:~/Singularity> ldd $OFFLINE_MAIN/lib/libg4detectors.so
linux-vdso.so.1 =>  (0x00007ffe3b261000)
	libg4detectors_io.so.0 => /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/release_new/new.2/lib/libg4detectors_io.so.0 (0x00007f7cd6403000)
	libphparameter.so.0 => /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/release_new/new.2/lib/libphparameter.so.0 (0x00007f7cd61da000)
	libphg4gdml.so.0 => /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/release_new/new.2/lib/libphg4gdml.so.0 (0x00007f7cd5f94000)
	libphool.so.0 => /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/release_new/new.2/lib/libphool.so.0 (0x00007f7cd5d58000)
	libCGAL.so.13 => /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/release_new/new.2/lib/libCGAL.so.13 (0x00007f7cd5b3a000)
	libSubsysReco.so.0 => /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/release_new/new.2/lib/libSubsysReco.so.0 (0x00007f7cd5937000)
...
```




Other potentially useful link - the Jenkins tool keeps track of the output from the underlying sPHENIX build every night. One can take a look at the [output](https://web.racf.bnl.gov/jenkins-sphenix/job/sPHENIX/job/singularity-download-validation/72/console) from running the Singularity container from scratch on the RCAS computers, which may provide some helpful feedback to compare to what kind of output you are getting locally.
