#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
#dnf5 install -y tmux

# fix cargo package key lock issue during image build process
export CARGO_HOME="/tmp/cargo"
mkdir -p "$CARGO_HOME"

dnf5 remove -y firefox firefox-langpacks htop nwg-panel nvtop

dnf5 install -y git cargo btop

dnf5 -y copr enable lionheartp/Hyprland
dnf5 install -y hyprland noctalia noctalia-greeter neovim greetd kitty distrobox
dnf5 -y copr disable lionheartp/Hyprland

dnf5 -y copr enable imput/helium
dnf5 install -y helium-bin
dnf5 -y copr disable imput/helium

# File Manager (A)
dnf5 -y copr enable relativesure/all-packages
dnf5 install -y superfile --setopt=install_weak_deps=False
dnf5 -y copr disable relativesure/all-packages

# File Manager (B)
# This is a alternative for advanced users specifically.
dnf5 -y copr enable lihaohong/yazi
dnf5 install -y yazi --setopt=install_weak_deps=False
dnf5 -y copr disable lihaohong/yazi

git clone https://github.com/Gerharddc/litterbox.git /tmp/litterbox
cd /tmp/litterbox/litterbox
cargo build --release
cp target/release/litterbox /usr/bin/
cd /

# Required for the below packages to work.
dnf5 install -y alsa-lib-devel

# Pre-installed games for simple entertainment
cargo install tetro-tui
cargo install chess-tui

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable greetd.service

# Copy the contents of system_files/ of the git repo to /
# this must happen AFTER installing packages and enabling core services
cp -avf "/ctx/system_files"/. /

# ctx fails to pull in git submodules like the lazyvim starter
# sparrow works around this issue by injecting it manually
git clone --depth 1 https://github.com/LazyVim/starter.git /etc/skel/.config/nvim
