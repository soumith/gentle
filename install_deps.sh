#!/bin/bash

set -e

echo "Installing dependencies..."

# Install OS-specific dependencies
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [[ -r /etc/os-release ]]; then
        # this will get the required information without dirtying any env state
        DIST_VERS="$( ( . /etc/os-release &>/dev/null
                        echo "$ID $VERSION_ID") )"
        DISTRO="${DIST_VERS%% *}" # get our distro name
        VERSION="${DIST_VERS##* }" # get our version number
    elif [[ -r /etc/redhat-release ]]; then
        DIST_VERS=( $( cat /etc/redhat-release ) ) # make the file an array
        DISTRO="${DIST_VERS[0],,}" # get the first element and get lcase
        VERS="${DIST_VERS[2]}" # get the third element (version)
    elif [[ -r /etc/lsb-release ]]; then
        DIST_VERS="$( ( . /etc/lsb-release &>/dev/null
                        echo "${DISTRIB_ID,,} $DISTRIB_RELEASE") )"
        DISTRO="${DIST_VERS%% *}" # get our distro name
        VERSION="${DIST_VERS##* }" # get our version number
    else # well, I'm out of ideas for now
        echo '==> Failed to determine distro and version.'
        exit 1
    fi

    if [[ "$DISTRO" = "ubuntu" ]]; then
        export DEBIAN_FRONTEND=noninteractive
        distribution="ubuntu"
        ubuntu_major_version="${VERSION%%.*}"
    # Detect CentOS
    elif [[ "$DISTRO" = "centos" ]]; then
        distribution="centos"
        centos_major_version="$VERSION"
    else
        echo '==> Only Ubuntu and CentOS distributions are supported.'
        exit 1
    fi
    if [[ $distribution == 'ubuntu' ]]; then
	sudo apt-get update
	sudo apt-get install -y zlib1g-dev automake autoconf git \
		libtool subversion libatlas3-base ffmpeg python-pip \
		python-dev wget unzip
    elif [[ $distribution == 'centos' ]]; then
        sudo yum install zlib-devel automake autoconf git \
            libtool subversion atlas-devel ffmpeg wget unzip \
            python-pip python-dev
    fi
	pip install .
elif [[ "$OSTYPE" == "darwin"* ]]; then
	brew install ffmpeg libtool automake autoconf wget

	sudo easy_install pip
	sudo pip install .
fi
