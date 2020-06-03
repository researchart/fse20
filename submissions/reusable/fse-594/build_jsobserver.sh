#!/bin/bash - 
# This script has been tested only on Debian and Mac OS X. You are recommended to use a Debian-like Linux dist or Mac OS X.

set -o nounset                              # Treat unset variables as an error

is_darwin=0
is_freebsd=0
is_linux=0
UNAME=$(uname)
case $UNAME in
    "Darwin") is_darwin=1;;
    "FreeBSD") is_freebsd=1;;
    "Linux") is_linux=1;;
esac

VERSION=71.0.3578.98
NTHREADS=32 # Number of *gclient sync* threads
TMPFS_SIZE=20G # Size of tmpfs in memory for build path. You need at least 20G memory for a DEBUG build.
FAILURE_THRESHOLD=64 # The build process stops until this number of jobs fail
BUILD_DIR=Release # Change this if you want to build at a different directory, e.g., JSObserver
PATCH_DIR=patch # Change this if you put the .patch files at a different directory


# HELP
print_help ()
{
  echo "Usage : ./build_jsobserver.sh options"
  echo "  e.g., ./build_jsobserver.sh --all"
  echo ""
  echo "options:"
  echo "  --help          print this message"
  echo "    please install the necessary development tools (depot_tools) first following the instructions at"
  echo "    https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions.md#Install"
  echo ""
  echo "  --all           execute all the necessary steps automatically, from downloading the source code, to building Chromium;"
  echo "    you should only run with this option at most ONCE and ONLY when you have not downloaded the source code"
  echo ""
  echo "  --fetch         fetch the source files of chromium (version $VERSION) and check out to a custom local development branch"
  echo "  --sync          run gclient sync to synchronize all files with (version $VERSION)"
  echo "  --deps          install the dependencies including CCACHE"
  echo "    you have to install the necessary packages yourself if this step fails"
  echo ""
  echo "  --patch         apply the patches in our repository to replace parts of the Chromium source"
  echo "  --run-hooks     run the Chromium-specific hooks to download additional binaries and other things you might need"
  echo ""
  echo "  --conf-local    create the $BUILD_DIR build directory with build arguments; use ONLY for a LOCAL build"
  echo "  --build-local   build Chromium locally using only your own machine"
} # ----------  end of function print_help ----------


# CHECK OUT CHROMIUM SRC
fetch_source ()
{
  git config --global core.precomposeUnicode true
  fetch --nohooks chromium
  cd $CHROMIUM/src
  git checkout -b dev $VERSION
} # ----------  end of function fetch_source ----------


# SYNC ALL FILES WITH THE CHECKOUT VERSION
gclient_sync ()
{
  gclient sync --with_branch_heads --jobs $NTHREADS
} # ----------  end of function gclient_sync ----------


# INSTALL BUILD DEPENDENCIES
install_deps ()
{
  if [ $is_darwin = 1 ]; then
    xcode-select --install # You can comment this line if you have installed XCode already
    if hash port 2>/dev/null; then
      sudo port install wget ccache docbook2X autoconf automake libtool
      sudo mkdir -p /usr/local/opt/lzo/lib/
      cd /usr/local/opt/lzo/lib/
      sudo ln -s /opt/local/lib/liblzo2.2.dylib . 2>/dev/null
    elif hash brew 2>/dev/null; then
      brew install wget ccache autoconf automake libtool
      echo ""
    else
      echo "Please install HomeBrew or MacPorts before you proceed!"
      exit 1
    fi

  elif [ $is_linux = 1 ]; then
    sudo apt-get install ccache
    echo ""
    cd $CHROMIUM/src
    sudo ./build/install-build-deps.sh --no-syms --no-arm --no-chromeos-fonts --no-nacl
  fi
} # ----------  end of function install_deps ----------


# RUN Chromium-specific hooks
run_hooks ()
{
  cd $CHROMIUM/src
  gclient runhooks
} # ----------  end of function run_hooks ----------


# CHECK OUT CUSTOM REPOSITORIES
apply_patch ()
{
  cd $CHROMIUM/src/third_party/blink/renderer && patch -p1 < $ROOT/$PATCH_DIR/blink.patch
  cd $CHROMIUM/src/v8 && patch -p1 < $ROOT/$PATCH_DIR/v8.patch
  cd $CHROMIUM/src/content && patch -p1 < $ROOT/$PATCH_DIR/content.patch
  cd $CHROMIUM/src/build/config/compiler && patch -p1 < $ROOT/$PATCH_DIR/build.patch
} # ----------  end of function fetch_repos ----------


# BUILD
conf_local_build ()
{
  cd $CHROMIUM/src
  mkdir -p out/$BUILD_DIR
  gn gen out/$BUILD_DIR '--args=cc_wrapper="ccache" use_jumbo_build=true is_debug=false enable_nacl=false'
} # ----------  end of function conf_local_build ----------


build_local ()
{
  export CCACHE_BASEDIR=$CHROMIUM
  cd $CHROMIUM/src
  time autoninja -C out/$BUILD_DIR chrome
} # ----------  end of function build_local ----------


mkdir -p chromium
ROOT=$PWD
cd chromium
CHROMIUM=$PWD
export GCLIENT_PY3=0

if [ $# -gt 0 ]; then
  if [ "$1" != "" ] ; then
    case "$1" in
      --fetch|--sync|--deps|--patch|--run-hooks|--conf-local|--build-local|--all|--help )
        if [ "$1" = "--fetch" ] || [ "$1" = "--all" ]; then
          fetch_source
        fi
        if [ "$1" = "--sync" ] || [ "$1" = "--all" ]; then
          gclient_sync
        fi
        if [ "$1" = "--deps" ] || [ "$1" = "--all" ]; then
          install_deps
        fi
        if [ "$1" = "--patch" ] || [ "$1" = "--all" ]; then
          apply_patch
        fi
        if [ "$1" = "--run-hooks" ] || [ "$1" = "--all" ]; then
          run_hooks
        fi
        if [ "$1" = "--conf-local" ] || [ "$1" = "--all" ]; then
          conf_local_build
        fi
        if [ "$1" = "--build-local" ] || [ "$1" = "--all" ]; then
          build_local
        fi
        if [ "$1" = "--help" ]; then
          print_help
        fi
        ;;

      *)
        echo "Your option "\"$1\"" is invalid"
        exit
        ;;

    esac    # --- end of case ---
  fi
else
  print_help
fi
