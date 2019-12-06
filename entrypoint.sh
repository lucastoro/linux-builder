#!/bin/bash

set -e -o pipefail

URL=''
DIR=/tmp
CNF=defconfig
CPU=$(grep processor /proc/cpuinfo | wc -l)

help() {
  echo "Usage: "
  echo "--url [URL]: the URL to a specific tarball to download and build (default: the latest upstream kernel source)."
  echo "--cpu [N.]: the number of threads to use to build the source (default: the number of hardware threads available)."
  echo "--dir [PATH]: a path within the container to store the sources (default: /tmp)."
  echo "--config [CONFIG]: the configuration to use (default: defconfig)."
}

while [ $# -ne 0 ] ; do
  case "$1" in
    --cpu|-j)
      CPU=$2
      shift
      ;;
    --url|-u)
      URL=$2
      shift
      ;;
    --dir|-d)
      DIR=$2
      shift
      ;;
    --config|-c)
      CNF=$2
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "invalid argument $1"
      usage
      exit 1
      ;;
  esac
  shift
done

test -n "$URL" || {

  URL=$(curl --silent https://www.kernel.org/index.html | \
        grep -A1 'latest_button' | \
        tail -1 | \
        sed -E 's/.*href="([^"]+)".*/\1/')

  echo "$URL" | grep -qE '^https?://' || {
    echo 'Cannot determine the URL to the latest source'
    exit 1
  }
}

TAR=$(echo $URL | sed -E 's/.*\/(.+)$/\1/')
SRC=$(echo $TAR | sed -E 's/(.+)\.tar\.[xg]z/\1/')
VER=$(echo $SRC | sed -E 's/linux-([0-9.]+)/\1/')

test -n "$VER" || {
  echo "Unexpected format for the URL: '$URL'"
  exit 1
}

echo '########################'
echo "# Building Linux $VER ($URL)"
echo "# Nr. CPUs: $CPU"
echo "# Output dir: $DIR"
echo "# Config: $CNF"
echo '########################'

mkdir -p $DIR && cd $DIR
test -f $TAR || (echo 'Downloading sources...' && wget -q $URL)
test -d $SRC || (echo 'Extracting tarball...' && tar -xf $TAR)
cd $SRC
echo 'Configuring project...' && make $CNF
echo 'Building kernel...' && time make -j $CPU
