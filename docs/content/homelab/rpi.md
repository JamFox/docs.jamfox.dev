---
title: "Raspberry Pi"
---

!!! info
    [Raspberry Pi Homepage](https://www.raspberrypi.com/) |
    [Raspberry Pi Software (Imager)](https://www.raspberrypi.com/software/) |
    [Raspberry Pi Docs](https://www.raspberrypi.com/documentation/) | 
    [Waveshare PoE HAT (B)](https://www.waveshare.com/wiki/PoE_HAT_(B)) 

In JamLab there are three Raspberry Pi's:

- Raspberry Pi Model 4B
- 2x Raspberry Pi Model 3B+

## Operating System

### OctoPrint

[OctoPrint](https://octoprint.org/) is used to control the 3D printer.

On installation (like with RPi Imager), set the main user as `octoprint` or something you are not using for anything else, messing with the main user groups/permissions/etc can cause issues.

Octoprint uses a git wrapper that blocks it from running as root user. To disable the git wrapper run `sudo rm /root/bin/git`

### Raspberry Pi OS

[Raspberry Pi OS](https://www.raspberrypi.com/software/)

#### Remove desktop environment

To save resources, the desktop environment can be removed from the Raspberry Pi OS:

```bash
sudo apt purge xserver* lightdm* raspberrypi-ui-mods vlc* lxde* chromium* desktop* gnome* gstreamer* gtk* hicolor-icon-theme* lx* mesa*
sudo apt autoremove
```

## Camera

To keep an eye on the rack and especially the 3D printer, a [Raspberry Pi Camera Module v2](https://www.raspberrypi.com/products/camera-module-v2/) is used.

Documentation for setting up the camera: [Raspberry Pi Camera Module v2 docs](https://www.raspberrypi.com/documentation/accessories/camera.html)

## PoE HAT

To simplify cabling, Waveshare PoE HAT (B) are used to power the Raspberry Pis using Ethernet cables.

Waveshare's documentation for setting up the HAT: [Waveshare PoE HAT (B)](https://www.waveshare.com/wiki/PoE_HAT_(B)). CharlesGodwin's script simplifies this further (provided you are using RPi OS): https://gist.github.com/CharlesGodwin/adda3532c070f6f6c735927a5d6e8555

My own repo for the script: [rpi-waveshare-poe-hat-b-script](https://github.com/JamFox/rpi-waveshare-poe-hat-b-script)
