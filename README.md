# MCSRLauncher Linux Build (AppImage)

This repository provides a **one-command bootstrap script** to automatically build **MCSRLauncher** for Linux as an AppImage.

The script:
- Downloads the **latest release JAR** from  
  https://github.com/MCSRLauncher/Launcher
- Fetches the application icon
- Builds a Linux AppImage using `jpackage` and `appimagetool`


## Quick Install / Build

```bash
mkdir MCSRLauncher-build
cd MCSRLauncher-build
curl -fsSL https://raw.githubusercontent.com/sinokadev/MCSRLauncher-Linux/main/bootstrap.sh | bash
```

## Requirements

### curl
The installer uses `curl`.

If you don’t have it installed:

**Debian / Ubuntu**
```bash
sudo apt install curl
```

**Arch**
```bash
sudo pacman -S curl
```

**Fedora**
```bash
sudo dnf install curl
```

### Java (JDK 17+ recommended)
You need a JDK that includes `jpackage` (Java 17 or newer).

## How It Works

1. Downloads the latest release JAR from  
   https://github.com/MCSRLauncher/Launcher/releases/latest/download/MCSRLauncher.jar
2. Places it into the `dist/` directory
3. Downloads the application icon into `assets/`
4. Fetches and runs `build.sh`
5. Produces a Linux `.AppImage` file

If the JAR is not found in the latest release, the script exits with a clear error message.

## Output

After a successful build:

```text
MCSRLauncher-x86_64.AppImage
```

Run it with:

```bash
chmod +x MCSRLauncher-x86_64.AppImage
./MCSRLauncher-x86_64.AppImage
```

## Notes

- Always builds from the **latest release**
- Fully automated
- No manual downloads required

## License

This repository only provides build scripts.
MCSRLauncher itself is licensed and maintained by its original authors.
