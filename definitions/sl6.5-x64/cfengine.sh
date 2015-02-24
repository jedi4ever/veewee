#!/bin/bash

# Lets not install untrusted packages to manage our infrastructure
Trusted_GPG_Fingerprint="EF49F970C3D4AEF5E557FB6D8D5A7684F97E94BE"
GPGURL="http://cfengine.com/pub/gpg.key"
GPGKEY="/tmp/cfengine_gpg.key"
YUMREPO="http://cfengine.com/pub/yum"



function main
{
    configure_repo
    retrieve_GPGKEY
    validate_GPGKEY
    install_GPGKEY
    install_cfengine
}

function configure_repo
{
    # Install Yum Client Repository Definition
    cat > /etc/yum.repos.d/cfengine.repo << EOM && return 0 || return 1
[cfengine]
name=cfengine
baseurl=$YUMREPO
enabled=1
gpgcheck=1
EOM
}

function retrieve_GPGKEY
{
    # Retrieve, validate, and install GPGKEY
    curl --silent --output $GPGKEY $GPGURL
    Found_GPG_Fingerprint=$(gpg --quiet --with-fingerprint $GPGKEY | grep fingerprint | cut -d "=" -f2 | sed 's/ //g')
}

function validate_GPGKEY
{
    if [ "$Found_GPG_Fingerprint" = "$Trusted_GPG_Fingerprint" ]; then
        echo "Trusting Retrieved Key: $GPGURL"
        return 0
    else
        return 1
    fi
}

function install_GPGKEY
{
    # We want to avoid possibly importing keys unnecissarily if they are already installed
    keyid=$(echo $(gpg --throw-keyids < $GPGKEY) | cut --characters=11-18 | tr [A-Z] [a-z])
    if ! rpm -q gpg-pubkey-$keyid > /dev/null 2>&1 ; then
        echo "Installing GPG public key with ID $keyid from $GPGKEY..."
        rpm --import $GPGKEY && return 0 || return 1
    else 
        # Found key already installed
        return 0
    fi
}

function install_cfengine
{
    yum -y install cfengine-community && return 0 || return 1
}

main


