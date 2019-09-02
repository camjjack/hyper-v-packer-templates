#!/bin/bash -e

debug=
log_path=packer-log.txt

box_out_dir="dist"
base_json="hyperv-windows-10.json"


output_name_prefix="output-windows-10"
vm_name_prefix="windows-10"
cpus="2"
ram_size="4096"
disk_size="200000"
username="vagrant"

clean() {
    echo "Cleaning build artifacts"
    rm -f $box_out_dir/virtualbox*.box
    rm -rf $output_name_prefix*
    rm -f $log_path
}
usage() {
    echo "./build-windows.sh [options]"
    echo "Options:"
    echo -e "\t--output_name_prefix [output_name_prefix]\tThe base name for the output directories. This is used to pass to following packer builds to generate the desktop box"
    echo -e "\t--vm_name_prefix [vm_name_prefix]\t\tThe base name for vm\"s that are created."
    echo -e "\t--cpus [cpus]\t\t\t\t\tThe number of cpus to allocate to the VM. Default: 2."
    echo -e "\t--ram_size [ram_size]\t\t\t\tThe ammount of RAM in bytes to allocate to the VM. Default: 4096"
    echo -e "\t--disk_size [disk_size]\t\t\t\tThe size of the hard disk drive in bytes used in the VM. Default: 200000"
    echo -e "\t--username [username]\t\t\t\tThe username for the VM. For simplicity the password will be set as the username. Default: vagrant"
    echo -e "\t-f, --force\t\t\t\t\tDefault behaivor is to skip any step that had been successfully completed before. Force will ensure all steps are run. Internally this is achieved by performing a clean before building."
    echo -e "\t-c, --clean\t\t\t\t\tCleans up all the artifacts of the build process."
    echo -e "\t-d, --debug\t\t\t\t\tCauses packer to be run with debug settings. Useful if the scripts are not working and you need to debug in flight."
    echo -e "\t-a, --add_vagrant\t\t\t\t\tCleans up all the artifacts of the build process."
    echo -e "\t-h, --help\t\t\t\t\tThis help"
}
while [ "$1" != "" ]; do
    case $1 in
        --output_name_prefix )  shift
                                output_name_prefix=$1
                                ;;
        --vm_name_prefix )      shift
                                vm_name_prefix=$1
                                ;;
        --cpus )                shift
                                cpus=$1
                                ;;
        --ram_size )            shift
                                ram_size=$1
                                ;;
        --disk_size )           shift
                                disk_size=$1
                                ;;
        --username )            shift
                                username=$1
                                ;;
        -f | --force )          clean
                                ;;
        -c | --clean )          clean
                                exit
                                ;;
        -d | --debug )          debug=1
                                ;;
        -a | --add_vagrant )    add_vagrant=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

base_args=("-var \"cpu=$cpus\"")
base_args+=("-var \"ram_size=$ram_size\"")
base_args+=("-var \"disk_size=$disk_size\"")
base_args+=("-var \"username=$username\"")
base_args+=("-var \"box_out_dir=$box_out_dir\"")
if [ $debug ]; then
    base_args+=("--debug")
    base_args+=("--on-error=ask")
    export PACKER_LOG=1
    export PACKER_LOG_PATH=$log_path
fi


# Vm names and locations based on the prefixes given as a parameter.
base_out_location=$output_name_prefix

base_box_location="$box_out_dir/virtualbox-$vm_name_prefix.box"
if [ ! -f $base_box_location ]; then
    echo "Building base image"
    
    win10_args=("-var \"vm_name=$vm_name_prefix\"")
    win10_args+=("-var \"output_name=$vm_name_prefix\"")
    win10_args+=("-var \"output_directory=$base_out_location\"")

    args=("packer")
    args+=("build")
    args+=("--only=virtualbox-iso")
    args+=("${base_args[@]}")
    args+=("${win10_args[@]}")
    args+=("$base_json")
    echo ${args[@]}
    export TMPDIR=/var/tmp/
    eval ${args[@]}
fi

if [ -f $base_box_location ]; then
    if [ $add_vagrant ]; then
        args=("vagrant")
        args+=("box")
        args+=("add")
        args+=("--force")
        args+=("--name ${vm_name_prefix}")
        args+=("${base_box_location}")
        echo ${args[@]}
        eval ${args[@]}
    fi
fi