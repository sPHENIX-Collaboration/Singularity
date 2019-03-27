#!/bin/bash

# Default parameter
# build='new';
build='root6';
URLBase='https://www.phenix.bnl.gov/WWW/publish/phnxbld/sPHENIX/Singularity/';
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
    echo "Usage: $0 [--build=<new|root6>] [--source=URL] [--target=directory] [--clean]";
    exit;
    shift # past argument with no value
    ;;
esac
done

echo "This macro download/update sPHENIX ${build} build to $DownloadBase"
echo "Source is at $URLBase"
echo ""
echo "If you have CVMFS file system directly mounted on your computer,"
echo "you can skip this download and mount /cvmfs/sphenix.sdcc.bnl.gov to the singularity container directly."

#cache check function
md5_check ()
{
	local target_file=$1
	local md5_cache=$2
	local new_md5=`curl -ks $target_file`
	# echo "new_md5 : $new_md5 ..."

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
	curl -k ${URLBase}/rhic_sl7_ext.simg > ${DownloadBase}/singularity/rhic_sl7_ext.simg 
	curl -ks ${URLBase}/rhic_sl7_ext.simg.md5 > ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5
else
	echo "${URLBase}/rhic_sl7_ext.simg has not changed since the last download"
	echo "- Its md5 sum is ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5 : " `cat ${DownloadBase}/singularity/rhic_sl7_ext.simg.md5`
	
fi



echo "--------------------------------------------------------"
echo "sPHENIX build images"
echo "--------------------------------------------------------"

declare -a images=("opt.tar.bz2" "offline_main.tar.bz2" "utils.tar.bz2")
mkdir -p ${DownloadBase}/.md5/${build}/


## now loop through the above array
for tarball in "${images[@]}"
do
	# echo "Downloading and decompress ${URLBase}/${build}/${tarball} ..."

	md5file="${DownloadBase}/.md5/${build}/${tarball}.md5";
	
	md5_check ${URLBase}/${build}/${tarball}.md5 ${md5file}
	if [ $? != 0 ]; then
		echo "Downloading ${URLBase}/${build}/${tarball} -> ${DownloadBase} ..."
		curl -k ${URLBase}/${build}/${tarball} | tar xjf -  
		curl -ks ${URLBase}/${build}/${tarball}.md5 > ${md5file}
	else
		echo "${URLBase}/${build}/${tarball} has not changed since the last download"
		echo "- Its md5 sum is ${md5file} : " `cat ${md5file}`		
	fi

done


echo "--------------------------------------------------------"
echo "Done! To run the sPHENIX container in shell mode:"
echo ""
echo "singularity shell -B cvmfs:/cvmfs cvmfs/sphenix.sdcc.bnl.gov/singularity/rhic_sl7_ext.simg"
echo "source /opt/sphenix/core/bin/sphenix_setup.sh -n $build"
echo ""
echo "More on singularity tutorials: https://www.sylabs.io/docs/"
echo "More on directly mounting cvmfs instead of downloading: https://github.com/sPHENIX-Collaboration/singularity"
echo "--------------------------------------------------------"


