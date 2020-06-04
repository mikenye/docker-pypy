FROM debian:stable-slim as builder

RUN set -x && \
    # install build prerequisites
    apt-get update && \
    apt-get install -y --no-install-recommends \
      bzip2 \
      ca-certificates \
      gcc \
      libbz2-dev \
      libexpat1-dev \
      libffi-dev \
      libgdbm-dev \
      liblzma-dev \
      libncursesw5-dev \
      libsqlite3-dev \
      libssl-dev \
      libunwind-dev \
      make \
      mercurial \
      pkg-config \
      python-pip \
      python2 \
      tar \
      tk-dev \
      zlib1g-dev \
      && \
    # get source for py3.7
    hg clone https://foss.heptapod.net/pypy/pypy /src/pypy && \
    # build intermediate pypy from latest stable 2.7 release
    cd /src/pypy && \
    BRANCH_PYPY_27_LATEST_STABLE=$(hg log --rev="tag()" --template="{tags}\n" | tr ' ' '\n' | grep "release-pypy2\.7" | grep -v "rc" | sort -r | head -1) && \
    hg update ${BRANCH_PYPY_27_LATEST_STABLE} && \
    cd /src/pypy/pypy/goal && \
    python2 ../../rpython/bin/rpython -Ojit targetpypystandalone --withoutmod-micronumpy --withoutmod-cpyext && \
    mkdir -p /src/pypy-intermediate && \
    cp -v pypy3-c libpypy3-c.so /src/pypy-intermediate/ && \
    # build proper from latest stable 3.x release using pypy
    cd /src/pypy && \
    BRANCH_PYPY_3x_LATEST_STABLE=$(hg log --rev="tag()" --template="{tags}\n" | tr ' ' '\n' | grep "release-pypy3\." | grep -v "rc" | sort -r | head -1) && \
    hg update ${BRANCH_PYPY_3x_LATEST_STABLE} && \
    cd /src/pypy/pypy/goal && \
    /src/pypy-intermediate/pypy3-c ../../rpython/bin/rpython -Ojit targetpypystandalone && \
    # package
    cd /src/pypy/pypy/tool/release && \
    python package.py --archive-name pypy --targetdir /src/pypyout.tar.bz2

FROM debian:stable-slim as final

COPY --from=builder /src/pypyout.tar.bz2 /src/pypyout.tar.bz2

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        tar \
        bzip2 \
        && \
    tar xvf /src/pypyout.tar.bz2 -C /opt && \
    apt-get remove -y \
        bzip2 \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/*
