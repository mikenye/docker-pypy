FROM debian:stable-slim as bootstrap_builder

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
      python-dev \
      python-pip \
      python2 \
      tar \
      tk-dev \
      zlib1g-dev \
      && \
    pip install \
      pycparser \
      && \
    # get latest stable 2.7 release of pypy
    hg clone https://foss.heptapod.net/pypy/pypy /src/pypy && \
    cd /src/pypy && \
    BRANCH_PYPY_27_LATEST_STABLE=$(hg log --rev="tag()" --template="{tags}\n" | tr ' ' '\n' | grep "release-pypy2\.7" | grep -v "rc" | sort -r | head -1) && \
    hg update ${BRANCH_PYPY_27_LATEST_STABLE}

# build pypy bootstrap from latest stable 2.7 release
RUN set -x && \
    cd /src/pypy/pypy/goal && \
    python2 ../../rpython/bin/rpython -Ojit targetpypystandalone --withoutmod-micronumpy --withoutmod-cpyext

# package pypy bootstrap
RUN set -x && \
    cd /src/pypy/pypy/tool/release && \
    python package.py --without-_tkinter --without-gdbm --archive-name pypy2-bootstrap --targetdir /src/pypy2bootstrap.tar.bz2

FROM debian:stable-slim as pypy_builder

COPY --from=bootstrap_builder /src/pypy2bootstrap.tar.bz2 /src/pypy2bootstrap.tar.bz2

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
      tar \
      tk-dev \
      zlib1g-dev \
      && \
    # install pypy bootstrap
    tar xvf /src/pypy2bootstrap.tar.bz2 -C /opt && \
    # get latest stable 3.x release of pypy
    hg clone https://foss.heptapod.net/pypy/pypy /src/pypy && \
    cd /src/pypy && \
    BRANCH_PYPY_3x_LATEST_STABLE=$(hg log --rev="tag()" --template="{tags}\n" | tr ' ' '\n' | grep "release-pypy3\." | grep -v "rc" | sort -r | head -1) && \
    hg update ${BRANCH_PYPY_3x_LATEST_STABLE}

# build pypy using bootstrap pypy
RUN set -x && \
    cd /src/pypy/pypy/goal && \
    /opt/pypy2-bootstrap/bin/pypy ../../rpython/bin/rpython -Ojit targetpypystandalone

# package final pypy
RUN set -x && \
    cd /src/pypy/pypy/tool/release && \
    /opt/pypy2-bootstrap/bin/pypy package.py --archive-name pypy --targetdir /src/pypyfinal.tar.bz2

# build final image
FROM debian:stable-slim as final

COPY --from=pypy_builder /src/pypyfinal.tar.bz2 /src/pypyfinal.tar.bz2

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        tar \
        bzip2 \
        && \
    tar xvf /src/pypyfinal.tar.bz2 -C /opt && \
    apt-get remove -y \
        bzip2 \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/*
