# mikenye/pypy

You almost certainly should not use this image, and instead use [the official pypy image](https://hub.docker.com/_/pypy).

My reasoning for maintaining this image is to include 32-bit ARM support (which is missing from the official image), and because I am a glutton for punishment.

Hopefully this helps someone out there looking for PyPy on 32-bit ARM...

## Tags

Regular builds will be performed on the most recent version of `pypy`. Once a version is superceded, it will no longer be regularly updated. For this reason, it is generally recommended to use either `latest` or `pypy3` tags unless a specific version is required.

### Multi-Architecture Images

* `latest` currently refers to the latest, stable, released version of pypy3.x
* `pypy3` will always refer to the latest, stable, released version of pypy3.x
* `pypy3.x` refers to the latest point release in that python family
* `pypy3.x.x` refers to the specific point release in that python family
* `pypy3.x.x-vY.Y.Y` refers to a specific point release in the python family (`3.x.x`) and a specific version of `pypy` (`vY.Y.Y`)

### Architecture Specific Images

It is recommended too use the multi-architecture images above. Should you require a single architecture image for some reason, all of the aformentioned tags are also available as single architecture.

The tag names will be appended with `_ARCH`, where `ARCH` is one of the following:
* `i386` for `linux/386` (x86 32-bit)
* `amd64` for `linux/amd64` (x86_64)
* `armv6` for `linux/arm/v6` (ARM 32-bit v6 `armel`)
* `armv7` for `linux/arm/v7` (ARM 32-bit v7 `armhf`)
* `arm64` for `linux/arm64` (ARM 64-bit v8 `aarch64`)

## Building

To build this yourself:

Firstly, clone the git repo:

```shell
git clone https://github.com/mikenye/docker-pypy.git /src/docker-pypy
```

Then, from the repo directory, perform a `docker build`:

```shell
cd /src/docker-pypy
docker build -t pypy .
```

Then wait a *very* long time for the builds to complete. On my x86_64 system it takes over an hour.

Although a `buildx.sh` script is included in the repository, this is set up for a specific build farm and likely won't work for you. Feel free to take a look and adjust for your environment.

## Using

TBC