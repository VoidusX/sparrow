# The Sparrow Project

Sparrow is a immutable distribution that stays lightweight, and secure at the same time, it focuses on a simple yet essential goal. The goal to be customizable, scriptable, and extendable; using both secure user-space containers, and a simple/common scripting language for many applications/programs.

## The Essentials

Sparrow comes with a simple and lightweight approach of packages/applications that fits to your needs. It comes with the following essentials:

- Hyprland (Wayland Compositor)
- Noctalia v5 (Desktop Shell)
- Noctalia Greeter (Greetd Greeter)
- Kitty (Terminal)
- Neovim (w/ Lazyvim Configuration)
- Helium (Web Browser w/ Privacy)
- Distrobox (Simple & Deployable Containers)
- Litterbox (Security First Containers)

**Any other packages/applications must be installed through flatpaks or through a Container.**

## Distributions
Sparrow uses the UBlue base image by default for building, making use of the base image's hardware akmods in a accessible manner.

In Sparrow, there are currently 3 mainline image tags to pick from:
- ``atomic-sparrow:stable`` (AMD/Intel)
- ``atomic-sparrow:stable-nvidia`` (Pre-Turing)
- ``atomic-sparrow:stable-nvidia-open`` (Turing+)

## Switching/Installing
> If you are switching to Sparrow using ``bootc``, use the compatible distribution otherwise you will experience a broken installation!
Migrating to Sparrow should be straight forward, provided that your system makes use of ``bootc``. If you are on a system that does not include ``bootc``, refer to installation via LiveCD.

### Switch via ``bootc``
Use ``bootc switch ghcr.io/voidusx/atomic-sparrow:stable`` to switch over from your existing bootc installation to Sparrow.
If you are using Secure Boot, use the ``--enforce-container-sigpolicy`` flag to ensure switching will not break your installation.

### Installing via LiveCD
Titanboa is provided as a installation process for the Ublue based Sparrow images; however, they do not come with a desktop session to test Sparrow.

To download the LiveCD(s), you can find them in Github Actions, Releases, or via the website (not implemented yet).
**Refer to Distributions section for available options to install your prefered image.**

## Build
Sparrow's Build process is similar to the standard UBlue image template format, see [ublue-os/image-template](https://github.com/ublue-os/image-template).
