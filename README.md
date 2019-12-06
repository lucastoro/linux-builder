# Linux Builder

A simple docker container to build the Linux kernel.

## Usage
### Building the image
```
git clone https://github.com/lucastoro/linux-builder.git
cd linux-builder
docker build -t linux-builder .
```
### Running the container
```
docker run --rm -it linux-builder
```
You can pass the following options to the container:
`--url, -u [URL]`: the URL to a specific tarball to download and build (default: the latest upstream kernel source).
`--cpu, -j [N.]`: the number of threads to use to build the source (default: the number of hardware threads available).
`--dir, -d [PATH]`: a path within the container to store the sources (default: /tmp).
`--config, -c [CONFIG]`: the configuration to use (default: defconfig).
`--help, -h`: shows a little help.

The `--dir` option can be used in combination of the --volume/-v option of docker itself to persist the tarball/source directory on the host.

The `make` command is run through `time` so that it is possible to check the time required to compile the kernel aside from the download archive inflation.
