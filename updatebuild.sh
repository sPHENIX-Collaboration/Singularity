#!/bin/bash

# Default parameter
build='new';
URLBase='https://www.phenix.bnl.gov/WWW/publish/phnxbld/sPHENIX/Singularity';
sysname='x8664_sl7'
DownloadBase='cvmfs/sphenix.sdcc.bnl.gov';
CleanDownload=false

# Parse input parameter
for i in "$@"
do
    case $i in
	-b=*|--build=*)
	    build="${i#*=}"
	    shift # past argument=value
	    ;;
	--sysname=*)
	    sysname="${i#*=}"
	    shift # past argument=value
	    ;;
	-s=*|--source=*)
	    URLBase="${i#*=}"
	    shift # past argument=value
	    ;;
	-t=*|--target=*)
	    DownloadBase="${i#*=}"
	    shift # past argument=value
	    ;;
	-c|--clean)
	    CleanDownload=true
	    shift # past argument=value
	    ;;
	--help|-h|*)
	    echo "Usage: $0 [--build=<new>] [--sysname=<x8664_sl7|gcc-8.3>] [--source=URL] [--target=directory] [--clean]";
	    exit;
	    shift # past argument with no value
	    ;;
    esac
done

echo "This macro download/update sPHENIX ${build} build to $DownloadBase"
echo "Source is at $URLBase"
echo ""
echo "If you have CVMFS file system directly mounted on your computer,"
echo "you can skip this download and mount /cvmfs/sphenix.sdcc.bnl.gov or /cvmfs/sphenix.opensciencegrid.org to the singularity container directly."

#cache check function
md5_check ()
{
    local target_file=$1
    local md5_cache=$2
    #echo "target_file $target_file"
    local new_md5=`curl -H 'Cache-Control: no-cache' -ks $target_file`
    #echo "new_md5 : $new_md5 ..."

    # echo "searching for $md5_cache ..."

    if [ -f $md5_cache ]; then
	# echo "verifying $md5_cache ..."
	local md5_cache=`cat $md5_cache`
	if [ "$md5_cache" = "$new_md5" ]; then
	    # echo "$target_file has not changed since the last download"
	    return 0;
	fi
    fi
    return 1;
}


if [ $CleanDownload = true ]; then

    echo "--------------------------------------------------------"
    echo "Clean up older download"
    echo "--------------------------------------------------------"

    if [ -d "$DownloadBase" ]; then
	echo "First, wiping out previous download at $DownloadBase ..."
        chmod -R 755 $DownloadBase # our boost headers are read only, need chmod to remove them
	/bin/rm -rf $DownloadBase
    else
	echo "Previous download folder is empty: $DownloadBase"
    fi

fi

echo "--------------------------------------------------------"
echo "Singularity image"
echo "--------------------------------------------------------"
#echo "${URLBase}/rhic_sl7_ext.simg -> ${DownloadBase}/singularity/"

mkdir -p ${DownloadBase}/singularity

md5_check ${URLBase}/rhic_sl7_ext.simg.md5 ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5

if [ $? != 0 ]; then
    echo "Downloading ${URLBase}/rhic_sl7_ext.simg -> ${DownloadBase}/singularity/ ..."
    curl -H 'Cache-Control: no-cache' -k ${URLBase}/rhic_sl7_ext.simg > ${DownloadBase}/singularity/rhic_sl7_ext.simg
    curl -H 'Cache-Control: no-cache' -ks ${URLBase}/rhic_sl7_ext.simg.md5 > ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5
else
    echo "${URLBase}/rhic_sl7_ext.simg has not changed since the last download"
    echo "- Its md5 sum is ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5 : " `cat ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5`
fi

echo "--------------------------------------------------------"
echo "Monte Carlos"
echo "--------------------------------------------------------"

md5_check ${URLBase}/MCEG.tar.bz2.md5 ${DownloadBase}/singularity/MCEG.tar.bz2.md5

if [ $? != 0 ]; then
    if [ -d ${DownloadBase}/${sysname}/MCEG ]; then
        echo "deleting old Monte Carlos"
	rm -rf ${DownloadBase}/${sysname}/MCEG
    fi
    echo "Downloading ${URLBase}/MCEG.tar.bz2 -> ${DownloadBase}/singularity/ ..."
    curl -H 'Cache-Control: no-cache' -k ${URLBase}/MCEG.tar.bz2   | tar xjf -
    curl -H 'Cache-Control: no-cache' -ks ${URLBase}/MCEG.tar.bz2.md5 > ${DownloadBase}/singularity/MCEG.tar.bz2.md5
else
    echo "${URLBase}/MCEG.tar.bz2 has not changed since the last download"
    echo "- Its md5 sum is ${DownloadBase}/singularity/MCEG.tar.bz2.md5 : " `cat ${DownloadBase}/singularity/MCEG.tar.bz2.md5`
fi



echo "--------------------------------------------------------"
echo "sPHENIX build images"
echo "--------------------------------------------------------"

declare -a images=("opt.tar.bz2" "offline_main.tar.bz2" "utils.tar.bz2")
mkdir -p ${DownloadBase}/${sysname}/.md5/${build}/


## now loop through the above array
for tarball in "${images[@]}"
do
    # echo "Downloading and decompress ${URLBase}/${build}/${tarball} ..."
    md5file="${DownloadBase}/${sysname}/.md5/${build}/${tarball}.md5";
    md5_check ${URLBase}/${sysname}/${build}/${tarball}.md5 ${md5file}
    if [ $? != 0 ]; then
	# clean up existing installation if it exists
	case "$tarball" in
	    opt*)
		deldir=${DownloadBase}/${sysname}/opt/sphenix/core
		if [ -d ${deldir} ]; then
		    echo "Cleaning ${deldir}"
                    rm -rf ${deldir}
		fi
		;;
	    offline*)
                # first remove the ${build} symlink if it exists
		if [ -e ${DownloadBase}/${sysname}/release/${build} ]; then
		    rm ${DownloadBase}/${sysname}/release/${build}
		fi
		deldir=${DownloadBase}/${sysname}/release/release_${build}
		if [ -d ${deldir} ]; then
		    echo "cleaning $deldir"
		    chmod -R 755 ${deldir}
		    rm -rf ${deldir}
		fi
		;;
	    utils*)
		deldir=${DownloadBase}/${sysname}/opt/sphenix/utils
		if [ -d ${deldir} ]; then
		    echo "Cleaning ${deldir}"
                    rm -rf ${deldir}
		fi
		;;
	esac

	echo "Downloading ${URLBase}/${sysname}/${build}/${tarball} -> ${DownloadBase} ..."
	curl -H 'Cache-Control: no-cache' -k ${URLBase}/${sysname}/${build}/${tarball} | tar xjf -
	curl -H 'Cache-Control: no-cache' -ks ${URLBase}/${sysname}/${build}/${tarball}.md5 > ${md5file}
    else
	echo "${URLBase}/${sysname}/${build}/${tarball} has not changed since the last download"
	echo "- Its md5 sum is ${md5file} : " `cat ${md5file}`
    fi

done


echo "--------------------------------------------------------"
echo "Done! To run the sPHENIX container in shell mode:"
echo ""
echo "singularity shell -B cvmfs:/cvmfs cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg"
if [ $sysname != 'x8664_sl7' ]
then
  echo "source /cvmfs/sphenix.sdcc.bnl.gov/$sysname/opt/sphenix/core/bin/sphenix_setup.sh -n $build"
else
  echo "source /opt/sphenix/core/bin/sphenix_setup.sh -n $build"
fi
echo ""
echo "More on singularity tutorials: https://www.sylabs.io/docs/"
echo "More on directly mounting cvmfs instead of downloading: https://github.com/sPHENIX-Collaboration/singularity"
echo "--------------------------------------------------------"
