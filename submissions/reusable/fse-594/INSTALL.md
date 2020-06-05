# Installation instructions

## Setup and Build

The following build script works only on Debian, Ubuntu and macOS.

```shell
# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$PATH:/path/to/depot_tools

# Fetch source and build
./build_jsobserver.sh --all
```

The above command will fetch the source code of Chromium version 71.0.3578.98, apply our patch to it, and build JSObserver.

For more information about the options, use:

```shell
./build_jsobserver.sh --help
```

When building on macOS, you might need to install an older version of MacOS SDK included by Xcode, e.g., MacOS SDK10.14 included by Xcode 10.0.
The SDKs are available [here](https://github.com/phracker/MacOSX-SDKs).

## Run on Linux

```shell
cd src
out/Release/chrome --no-sandbox
```

## Run on macOS

```shell
cd src
out/Release/Chromium.app/Contents/MacOS/Chromium --no-sandbox
```
