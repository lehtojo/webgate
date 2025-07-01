# Webgate

A Linux image builder that creates a bootable system operating entirely from an initial ramdisk (initrd), designed to launch Chromium in DRM/GBM mode with minimal dependencies.

## Overview

Webgate builds a Linux environment that:
- Boots directly into a ramdisk-based system
- Provides essential components required to run Chromium reliably
- Uses DRM (Direct Rendering Manager) and GBM (Generic Buffer Management) for hardware-accelerated graphics
- Reduces dependencies between the Linux kernel and Chromium browser while maintaining functionality
- Creates bootable UEFI images for bare-metal deployment

## Architecture

The system consists of several core components:

### Core Modules
- **Linux Kernel** - Custom configured kernel with DRM/GBM support
- **libdrm** - Direct Rendering Manager userspace library
- **Mesa** - 3D graphics library with hardware-specific Gallium drivers
- **libglvnd** - OpenGL Vendor-Neutral Dispatch library
- **Linux Firmware** - GPU firmware files for various hardware

### Build System
- **Dockerized Environment** - Reproducible builds using Debian Trixie
- **Modular Architecture** - Each component has independent build, setup, and install scripts
- **UEFI Boot Support** - Creates bootable EFI images using systemd-ukify

## Prerequisites

- Docker
- Privileged container support (for loop device mounting)

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lehtojo/webgate
   cd webgate
   ```

2. **Build the complete system:**
   ```bash
   ./build.sh
   ```

3. **The build process will:**
   - Sync module source code
   - Configure and build all components
   - Create a functional root filesystem
   - Package everything into a bootable UEFI image

4. **Output:**
   - `out/system.img` - Bootable disk image
   - `out/bootloader.efi` - UEFI bootloader
   - `out/filesystem.cpio` - Initial ramdisk

## Manual Build Process

For more control, you can run individual build phases:

```bash
./control.sh sync attach setup build install postinstall filesystem bootloader image
```

### Build Phases

- **sync** - Download/update module source code
- **attach** - Prepare module dependencies
- **setup** - Configure build systems (Meson, Make)
- **build** - Compile all modules
- **install** - Install to staging directory
- **postinstall** - Copy additional files and finalize
- **filesystem** - Create initrd archive
- **bootloader** - Generate UEFI bootloader
- **image** - Create bootable disk image

## Configuration

### GPU Support
Graphics hardware support through Mesa drivers:
- Intel integrated graphics (i915, iris)
- NVIDIA graphics (Nouveau)
- Software rendering fallback (LLVMpipe, Softpipe)
- AMD graphics (RadeonSI, AMDGPU)
- Additional hardware support via Mesa's Gallium drivers

### Module Configuration
Each module contains configuration files:
- `config.json` - Git repository and commit information
- `setup.sh` - Build system configuration
- `build.sh` - Compilation commands
- `install.sh` - Installation scripts

### Customization
- Add custom root filesystem files to `extra/` directory
- Modify kernel command line in `data/commandline/commandline.txt`
- Adjust module configurations in respective `setup.sh` scripts

## Development

### Adding New Modules
1. Create module directory in `modules/`
2. Add required scripts: `setup.sh`, `build.sh`, `install.sh`
3. Optionally add `config.json` for Git-based modules

## Goals

This project aims to create a path from Linux kernel to Chromium browser, reducing system complexity while maintaining hardware compatibility and functionality.

## License

See LICENSE file for details.