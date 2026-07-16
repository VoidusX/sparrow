#!/usr/bin/bash
# Live-ISO payload build. Runs INSIDE the payload image build (privileged).
# Minimal first cut ported from github.com/ublue-os/titanoboa examples/bazzite,
# trimmed to: live session (Hyprland + Noctalia) + Anaconda install
set -exo pipefail
{ export PS4='+( ${BASH_SOURCE}:${LINENO} ): '; } 2>/dev/null

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_IMAGE="${INSTALL_IMAGE:-ghcr.io/voidusx/sparrow:latest}"

# /root is a symlink on these images; make sure its target exists.
mkdir -p "$(realpath /root)"
# bwrap (flatpak/dnf scriptlets) needs /proc/sys writable during the build.
mount -o remount,rw /proc/sys || true

# Install flatpaks
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -r flatpak install -y --noninteractive <"$SCRIPT_DIR/flatpaks.list"

# Embed the image to install so the live ISO can install fully offline.
podman pull "${INSTALL_IMAGE}"

# Secure Boot: swap the ublue-signed kernel for a vanilla Fedora-signed one so
# the ISO boots SB-on anywhere. Must run BEFORE the dracut regen below so the
# initramfs targets the new kernel.
bash /src/titanoboa_hook_preinitramfs.sh

# Live initramfs: add the dmsquash-live modules so the ISO can mount its
# squashfs as the live root. Without this the ISO boots but finds no root.
dnf install -y dracut-live
kernel="$(kernel-install list --json pretty | jq -r '.[] | select(.has_kernel == true) | .version')"
DRACUT_NO_XATTR=1 dracut -v --force --zstd --reproducible --no-hostonly \
    --add "dmsquash-live dmsquash-live-autooverlay" \
    "/usr/lib/modules/${kernel}/initramfs.img" "${kernel}"

# Live session scripts.
dnf install -y livesys-scripts
sed -i "s/^livesys_session=.*/livesys_session=hyprland/" /etc/sysconfig/livesys
systemctl enable livesys.service livesys-late.service

# Anaconda + a kickstart that installs from the embedded image
# (containers-storage transport = offline). This is the actual install path.
dnf install -y --enable-repo=fedora-cisco-openh264 --allowerasing \
    anaconda-live firefox libblockdev-btrfs libblockdev-lvm libblockdev-dm
mkdir -p /var/lib/rpm-state  # Anaconda Web UI needs this
cat >>/usr/share/anaconda/interactive-defaults.ks <<EOF

ostreecontainer --url=${INSTALL_IMAGE} --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
EOF

# Signed Images
cat <<EOF >>/usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%post --erroronfail --log=/tmp/anacoda_custom_logs/bootc-switch.log
bootc switch --mutate-in-place --enforce-container-sigpolicy --transport registry ${INSTALL_IMAGE}
%end
EOF

# Install Flatpaks
cat <<'EOF' >>/usr/share/anaconda/post-scripts/install-flatpaks.ks
%post --erroronfail --nochroot --log=/tmp/anacoda_custom_logs/install-flatpaks.log
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/"
mkdir -p "$target"
rsync -aAXUHKP --filter='-x security.selinux' /var/lib/flatpak "$target"
%end
EOF

# Disable Fedora Flatpak Repo
cat <<EOF >>/usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%post --erroronfail --log=/tmp/anacoda_custom_logs/disable-fedora-flatpak.log
systemctl disable flatpak-add-fedora-repos.service || :
%end
EOF

CONFIG_FILE="${ROOTFS_DIR}/etc/greetd/config.toml"
# Check if initial_session already exists to avoid duplicates
if ! grep -q "^\[initial_session\]" "$CONFIG_FILE"; then
    echo "Injecting initial_session into greetd config..."

    # Append the initial_session block
    cat >> "$CONFIG_FILE" <<EOF

[initial_session]
# Forces autologin for the live user on the FIRST boot only
command = "Hyprland -c /usr/share/hypr/hyprland.lua"
user = "liveuser"
EOF
else
    echo "initial_session already present in greetd config."
fi

# ISO builder bits + the EFI layout titanoboa's build_iso.sh expects.
dnf install -y grub2-efi-x64-cdboot xorriso isomd5sum
mkdir -p /boot/efi
cp -av /usr/lib/efi/*/*/EFI /boot/efi/ || true
cp -v /boot/efi/EFI/fedora/grubx64.efi /boot/efi/EFI/BOOT/fbx64.efi || true

# UTC clock for the live session.
systemd-firstboot --timezone UTC || true

# The live root is a small tmpfs overlay; ostree install needs room in /var/tmp.
# `|| :` because the dnf build cache is bind-mounted at /var/tmp/libdnf5 during
# this build, so the mountpoint itself can't be removed (and need not be — the
# cache mount isn't committed to the image, and var-tmp.mount overlays it at boot).
rm -rf /var/tmp || :
mkdir -p /var/tmp
cat >/etc/systemd/system/var-tmp.mount <<'EOF'
[Unit]
Description=Larger tmpfs for /var/tmp on the live system
[Mount]
What=tmpfs
Where=/var/tmp
Type=tmpfs
Options=size=50%,nr_inodes=1m
[Install]
WantedBy=local-fs.target
EOF
systemctl enable var-tmp.mount

# The ISO config titanoboa requires at this exact path.
mkdir -p /usr/lib/bootc-image-builder
cp /src/iso.yaml /usr/lib/bootc-image-builder/iso.yaml

# final patching for noctalia shell to detect the application
sudo sed -i 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
update-desktop-database

dnf clean all || true
