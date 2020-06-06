# mikenye/pypy

You almost certainly **_should not_** use this image, and instead use [the official pypy image](https://hub.docker.com/_/pypy).

My reasoning for maintaining this image is to include ARMv7 support (which is missing from the official image), and because I am a glutton for punishment.

## Tags

* `latest` currently refers to the latest, stable, released version of pypy3.x
* `3` will always refer to the latest, stable, released version of pypy3.x
* There will be more specific version tags, so if you need a particular version please have a look throug the available tags
* Once a version is superceded, it will no longer be regularly updated

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

## Using

TBC