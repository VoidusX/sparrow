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

dnf5 install -y git cargo

dnf5 -y copr enable lionheartp/Hyprland
dnf5 install -y hyprland noctalia noctalia-greeter neovim greetd kitty distrobox
dnf5 -y copr disable lionheartp/Hyprland

dnf5 -y copr enable imput/helium
dnf5 install -y helium-bin
dnf5 -y copr disable imput/helium

git clone https://github.com/Gerharddc/litterbox.git /tmp/litterbox
cd /tmp/litterbox/litterbox
cargo build --release
cp target/release/litterbox /usr/bin/
cd /

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
