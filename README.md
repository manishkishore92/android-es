<div align="center">

# Android ES

**Android ROM maintainer toolkit for source setup, device trees, vendor trees, kernels, build logs, release files, and OTA metadata.**

![Shell](https://img.shields.io/badge/Shell-Bash-1f425f?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Linux-333333?style=flat-square)
![Focus](https://img.shields.io/badge/Focus-Android%20ROM%20Maintainers-blue?style=flat-square)
![Maintainer](https://img.shields.io/badge/Maintainer-Manish%20Kishore-6f42c1?style=flat-square)

</div>

---

## Overview

Android ES is a terminal-based toolkit for Android ROM, device tree, vendor tree, and kernel maintainers. It brings common maintainer tasks into one command-line workflow so developers can check their build environment, manage ROM sources, inspect device trees, analyze failed logs, prepare release files, generate OTA metadata, and back up maintainer configuration without rewriting the same commands again and again.

The project is focused on real Android source workflows: AOSP-based ROMs, local manifests, device bring-up, vendor blob checks, kernel builds, failed build debugging, release preparation, and maintainer reports.

```bash
./android-es help
```

---

## Why Android ES exists

Android ROM work usually involves many repeated tasks:

- Setting up a Linux machine for Android builds
- Initializing and syncing ROM sources
- Managing device, vendor, and kernel paths
- Checking makefiles, overlays, sepolicy, VINTF files, and recovery files
- Building ROMs and kernels with logs saved automatically
- Finding the real reason behind a failed Soong, Ninja, Java, sepolicy, or vendor build error
- Preparing release notes, checksums, build information, and OTA metadata
- Keeping maintainer profiles, local manifests, reports, and logs organized

Android ES keeps those tasks inside one project and one launcher.

---

## Features

| Area | What it does |
| --- | --- |
| Environment doctor | Checks build tools, Java, repo, Git, ADB, Fastboot, RAM, swap, disk space, and project paths |
| Maintainer dashboard | Shows ROM, device, source, tree, kernel, log, and report status from one command |
| ROM source manager | Initializes, syncs, and checks Android source status using config values |
| Device inspector | Reviews AndroidProducts.mk, BoardConfig.mk, device makefiles, sepolicy, overlays, init files, recovery files, VINTF files, dynamic partitions, and A/B indicators |
| Vendor inspector | Checks vendor makefiles, proprietary folders, firmware folders, overlays, XML files, and missing blob references |
| Kernel tools | Inspects kernel trees, checks defconfig, builds kernels, saves logs, and prepares AnyKernel3 package folders |
| Build command | Runs configured ROM build commands with log capture and build report generation |
| Log analyzer | Detects common Android build failure patterns and suggests what to check next |
| Release generator | Creates release folders with ROM zip, checksum, release notes, build info, and flash instructions |
| Changelog generator | Collects recent Git commits from device, vendor, kernel, and source trees |
| OTA metadata helper | Generates OTA JSON metadata for hosted ROM builds |
| Backup system | Archives configs, profiles, local manifests, logs, reports, releases, changelogs, and OTA files |

---

## Repository structure

```text
android-es/
  android-es                 Main launcher
  core/                      Shared helpers used by commands
  commands/                  Command modules for source, device, vendor, kernel, logs, release, OTA, backup
  scripts/                   Linux setup scripts for Ubuntu, Arch, and Fedora
  templates/                 Release, OTA, local manifest, and profile templates
  examples/                  Example configuration files
  profiles/                  Device profile examples
  docs/                      Detailed documentation
  README.md                  Project documentation
  .gitignore                 Ignore rules for logs, outputs, backups, and generated files
```

The repository keeps source files, scripts, docs, examples, and templates only. Generated logs, reports, backups, release folders, OTA files, and ROM outputs are ignored by Git.

---

## Requirements

Android ES is designed for Linux systems used for Android source builds.

Recommended tools:

- Bash
- Git
- Python 3
- repo tool
- Java version required by your ROM branch
- ADB and Fastboot
- ccache
- curl, tar, awk, sed, grep, find, sha256sum
- Enough storage for Android source and build outputs
- Enough RAM and swap for large Android builds

For Android ROM compilation, always follow the official dependency requirements of the ROM source you are building.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/manishkishore92/android-es.git
cd android-es
```

Make the launcher and setup scripts executable:

```bash
chmod +x android-es scripts/*.sh
```

Check the command list:

```bash
./android-es help
```

---

## Linux build environment setup

Android ES includes setup helpers for common Linux distributions.

Ubuntu:

```bash
./scripts/ubuntu-setup.sh
```

Arch Linux:

```bash
./scripts/arch-setup.sh
```

Fedora:

```bash
./scripts/fedora-setup.sh
```

After installing packages, run the doctor command:

```bash
./android-es doctor
```

The doctor command checks the system and gives direct suggestions when something important is missing.

---

## First setup

Create local config files from the included examples:

```bash
cp examples/android-es.config.example android-es.config
cp examples/maintainer.conf.example maintainer.conf
mkdir -p profiles
cp examples/profile.conf.example profiles/sweet.conf
```

Edit the copied files before running source, build, kernel, release, or OTA commands.

Main project config:

```bash
android-es.config
```

Maintainer details:

```bash
maintainer.conf
```

Device profiles:

```bash
profiles/<device>.conf
```

Android ES loads configuration in this order:

1. `android-es.config`
2. `maintainer.conf`
3. `profiles/<device>.conf` when `DEVICE_PROFILE` or `DEVICE_CODENAME` is set

---

## Example configuration

```bash
ROM_NAME="LineageOS"
ROM_BRANCH="lineage-22.2"
MANIFEST_URL="https://github.com/LineageOS/android.git"
ANDROID_ROOT="$HOME/android/lineage"

DEVICE_CODENAME="sweet"
DEVICE_BRAND="xiaomi"
DEVICE_PROFILE="sweet"
LUNCH_TARGET="lineage_sweet-userdebug"
BUILD_COMMAND="mka bacon"
JOBS="8"

DEVICE_TREE="$ANDROID_ROOT/device/xiaomi/sweet"
VENDOR_TREE="$ANDROID_ROOT/vendor/xiaomi/sweet"
KERNEL_TREE="$ANDROID_ROOT/kernel/xiaomi/sweet"
KERNEL_DEFCONFIG="vendor/sweet_defconfig"
KERNEL_ARCH="arm64"
KERNEL_SUBARCH="arm64"
KERNEL_OUT="out"

ANYKERNEL_DIR="$HOME/android/AnyKernel3"
ROM_TYPE="UNOFFICIAL"
```

Maintainer config:

```bash
MAINTAINER_NAME="Manish Kishore"
MAINTAINER_GITHUB="manishkishore92"
MAINTAINER_LOCATION="Baliya, UP"
```

---

## Command reference

| Command | Purpose |
| --- | --- |
| `./android-es help` | Show available commands |
| `./android-es doctor` | Check system tools, build environment, memory, swap, disk, and configured paths |
| `./android-es dashboard` | Show maintainer workspace status |
| `./android-es source init` | Initialize Android source using `MANIFEST_URL`, `ROM_BRANCH`, and `ANDROID_ROOT` |
| `./android-es source sync` | Sync Android source using configured job count |
| `./android-es source status` | Show source path and repo status |
| `./android-es device inspect` | Inspect configured device tree |
| `./android-es vendor inspect` | Inspect configured vendor tree and blob references |
| `./android-es kernel inspect` | Inspect configured kernel tree and defconfig |
| `./android-es kernel build` | Build kernel using configured kernel values |
| `./android-es kernel package` | Prepare an AnyKernel3 package folder |
| `./android-es build rom` | Build ROM using configured lunch target and build command |
| `./android-es log analyze <file>` | Analyze a failed build log |
| `./android-es release create <zip>` | Create release folder, checksum, notes, and build info |
| `./android-es changelog generate` | Generate changelog from Git logs |
| `./android-es ota metadata <zip> <url>` | Generate OTA metadata JSON |
| `./android-es backup create` | Create backup archive for configs and generated maintainer files |
| `./android-es backup restore <archive>` | Restore a backup archive into the project folder |

---

## Maintainer workflow

A normal ROM maintainer workflow can look like this:

```bash
./android-es doctor
./android-es dashboard
./android-es source init
./android-es source sync
./android-es device inspect
./android-es vendor inspect
./android-es kernel inspect
./android-es build rom
```

If the build fails:

```bash
./android-es log analyze logs/build-sweet-YYYYMMDD-HHMMSS.log
```

After a successful build:

```bash
./android-es release create out/target/product/sweet/lineage-22.2-YYYYMMDD-UNOFFICIAL-sweet.zip
./android-es changelog generate
./android-es ota metadata out/target/product/sweet/lineage-22.2-YYYYMMDD-UNOFFICIAL-sweet.zip <published-download-url>
./android-es backup create
```

---

## Dashboard

The dashboard gives a quick view of the configured workspace:

```bash
./android-es dashboard
```

It reports details such as:

- ROM name and branch
- Android source path
- Device codename and brand
- Device tree status
- Vendor tree status
- Kernel tree status
- Last saved build log
- Last generated report
- Maintainer information

Use it before starting long syncs or builds.

---

## Environment doctor

Run the doctor command after setup or before a large build:

```bash
./android-es doctor
```

It checks:

- Git
- repo tool
- Java
- Python
- ADB
- Fastboot
- ccache
- RAM
- Swap
- Disk space
- Android source path
- Device tree path
- Vendor tree path
- Kernel tree path

When a required tool is missing or a system value looks low, Android ES prints a practical next step instead of only showing a failure.

---

## Device tree inspection

Inspect the configured device tree:

```bash
./android-es device inspect
```

The inspector checks common Android device tree files and folders, including:

- `AndroidProducts.mk`
- `BoardConfig.mk`
- `device.mk`
- `vendorsetup.sh`
- Product makefiles
- `proprietary-files.txt`
- `extract-files.sh`
- sepolicy folders
- overlay folders
- init files
- recovery files
- VINTF manifests
- dynamic partition indicators
- A/B partition indicators

This helps catch missing files before wasting time on a long build.

---

## Vendor tree inspection

Inspect the configured vendor tree:

```bash
./android-es vendor inspect
```

The vendor inspector checks:

- Vendor makefiles
- Android.bp files
- proprietary blob folders
- firmware folders
- XML permission files
- overlay folders
- missing proprietary file references
- device tree `proprietary-files.txt` links

This is useful after extracting blobs, switching branches, or changing local manifests.

---

## Kernel workflow

Inspect the configured kernel tree:

```bash
./android-es kernel inspect
```

Build the kernel:

```bash
./android-es kernel build
```

Prepare an AnyKernel3 package folder:

```bash
./android-es kernel package
```

Kernel settings are read from the main config or device profile:

```bash
KERNEL_TREE="$ANDROID_ROOT/kernel/xiaomi/sweet"
KERNEL_DEFCONFIG="vendor/sweet_defconfig"
KERNEL_ARCH="arm64"
KERNEL_SUBARCH="arm64"
KERNEL_OUT="out"
ANYKERNEL_DIR="$HOME/android/AnyKernel3"
```

---

## Build log analyzer

Analyze a failed build log:

```bash
./android-es log analyze logs/build-sweet-YYYYMMDD-HHMMSS.log
```

The analyzer looks for common failure groups:

- Missing modules
- Missing dependencies
- Vendor blob issues
- SELinux policy errors
- Soong and Blueprint errors
- Ninja failures
- Java version problems
- Kernel compiler errors
- Out-of-memory failures
- Disk-space failures
- VINTF compatibility errors

The output includes a matched line, a likely reason, and a suggested area to check next.

---

## Release workflow

Create a release folder from a ROM zip:

```bash
./android-es release create out/target/product/sweet/lineage-22.2-YYYYMMDD-UNOFFICIAL-sweet.zip
```

Android ES creates:

```text
releases/
  sweet-YYYYMMDD-HHMMSS/
    lineage-22.2-YYYYMMDD-UNOFFICIAL-sweet.zip
    checksums.txt
    release-notes.md
    build-info.json
    flash-instructions.md
```

The release folder includes useful files for sharing builds with testers or publishing builds later.

---

## Changelog generation

Generate a changelog from configured Git trees:

```bash
./android-es changelog generate
```

Android ES checks recent commits from:

- Device tree
- Vendor tree
- Kernel tree
- Android source tree

Generated changelogs are saved under:

```text
changelogs/
```

---

## OTA metadata

Generate OTA metadata JSON for a ROM zip:

```bash
./android-es ota metadata out/target/product/sweet/lineage-22.2-YYYYMMDD-UNOFFICIAL-sweet.zip <published-download-url>
```

The generated JSON includes:

- Device codename
- ROM name
- ROM branch
- ROM type
- Build timestamp
- File name
- File size
- SHA256 ID
- Download URL
- Maintainer details

Generated OTA files are saved under:

```text
ota/
```

---

## Backup and restore

Create a backup:

```bash
./android-es backup create
```

The backup command archives useful maintainer files such as:

- `android-es.config`
- `maintainer.conf`
- `profiles/`
- `logs/`
- `reports/`
- `releases/`
- `changelogs/`
- `ota/`
- local manifests from the configured Android source tree

Restore a backup:

```bash
./android-es backup restore backups/android-es-backup-YYYYMMDD-HHMMSS.tar.gz
```

---

## Documentation

Detailed docs are available inside the `docs/` folder:

- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [Command Reference](docs/command-reference.md)
- [Maintainer Workflow](docs/maintainer-workflow.md)
- [Source Manager](docs/source-manager.md)
- [Device Inspector](docs/device-inspector.md)
- [Kernel Tools](docs/kernel-tools.md)
- [Log Analyzer](docs/log-analyzer.md)
- [Release Workflow](docs/release-workflow.md)
- [Troubleshooting](docs/troubleshooting.md)

---

## Important notes

Android ES is a helper toolkit. It does not replace ROM source documentation, device-specific instructions, kernel documentation, or recovery flashing guides.

Before sharing a build, always verify:

- Correct device codename
- Correct firmware base
- Correct recovery instructions
- Correct ROM branch
- Boot, modem, vendor, and firmware compatibility
- Known device-specific issues
- SHA256 checksum

Never flash a build on an unsupported device.

---

## Maintainer

**Manish Kishore**  
Android ROM, device tree, and kernel.

GitHub: [@manishkishore92](https://github.com/manishkishore92)
