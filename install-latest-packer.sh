#!/bin/bash
ARCH=$(uname -m)
PROG_LOC=/usr/bin/
URL="https://www.packer.io/downloads.html"
downloadURL=$(curl -s $URL|grep -oP "https://releases.hashicorp.com/packer\S+.zip" | head -n 1)
version=$(echo $downloadURL|egrep -o "\/([0-9]{1,}\.)+[0-9]{1,}\/"|sed 's/\///g')

downloadURL="https://releases.hashicorp.com/packer/$version/packer_${version}_linux_amd64.zip"
echo "Download URL is : $downloadURL"
downloadCMD="curl -so /tmp/packer.zip $downloadURL"

if $($downloadCMD);then
	sudo unzip -q -o /tmp/packer.zip -d $PROG_LOC
	checkver=$(${PROG_LOC}packer -v|egrep -o "([0-9]{1,}\.)+[0-9]{1,}")
	if [[ "$checkver" == "$version" ]]; then
		echo "succesfully installed to $PROG_LOC"
		rm -rf /tmp/packer.zip

	fi
else
	echo "Download unsuccesfull"
	exit 1
fi
