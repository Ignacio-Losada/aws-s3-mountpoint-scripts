#!/bin/bash
set -e

function die() {
    echo "[ERROR] ${1}"
    exit 1
}

function warn() {
    echo "[WARNING] ${1}"
}

function info() {
    echo "[INFO] ${1}"
}

function os_id() {
    if [[ $(uname -s) == "Linux" ]]; then
        OS_ID=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }' | tr -d '"')
    elif [[ $(uname -s) == "Darwin" ]]; then
        OS_ID=darwin
    else
        OS_ID=unknown
    fi
    echo "${OS_ID}"
}

download() {
    curl -O "${1}" || wget "${1}"
}

install_deb() {
    download https://s3.amazonaws.com/mountpoint-s3-release/latest/"${OS_ARCH}"/mount-s3.deb
    sudo apt-get install -y ./mount-s3.deb && rm -rf mount-s3.deb 
}

install_rpm() {
    download https://s3.amazonaws.com/mountpoint-s3-release/latest/"${OS_ARCH}"/mount-s3.rpm
    sudo yum install -y ./mount-s3.rpm && rm -rf mount-s3.rpm
}

OS_ID=$(os_id)
OS_ARCH=$(uname -m)


if [[ $OS_ID == "ubuntu" ]]; then
    OS_RELEASE=$(awk '/^DISTRIB_RELEASE=/' /etc/*-release | awk -F'=' '{ print tolower($2) }' | tr -d '"')
    if [[ "${OS_RELEASE}" == "22.04" ]]; then
        die "Unsupported Ubuntu version"
    fi
fi

if [[ $OS_ARCH == "aarch64" ]]; then
    OS_ARCH=arm64
fi

case $OS_ID in
    amzn)
        info "Installing dependencies for Amazon Linux"
        install_rpm
        ;;
    ubuntu)
        info "Installing dependencies for Ubuntu"
        install_deb
        ;;
    rhel)
        info "Installing dependencies for RHEL"
        install_rpm
        ;;
    debian)
        info "Installing dependencies for Debian"
        install_deb
        ;;
    rocky)
        info "Installing dependencies for Rocky Linux"
        install_rpm
        ;;
    centos)
        info "Installing dependencies for CentOS"
        install_rpm
        ;;
    fedora)
        info "Installing dependencies for Fedora"
        install_rpm
        ;;
    *)
        die "Unsupported OS"
        ;;
esac

info "Installation complete" && exit 0
