FROM rust:1.23

# Base dependencies
RUN apt-get update -qqy \
 && apt-get install -qqy --no-install-recommends \
    locales \
    libsodium18 \
    libsodium-dev \
    make \
    cmake \
    meson \
    ninja-build \
    flex \
    valgrind \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Fix locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Add wrapper scripts
ADD saltyrtc-server-launcher /usr/local/bin/saltyrtc-server-launcher
ADD generate-cert.sh /saltyrtc/certs/generate-cert.sh

# Update permissions
RUN chmod a+w /saltyrtc && \
    chmod a+x /saltyrtc/certs/generate-cert.sh && \
    chmod a+x /usr/local/bin/saltyrtc-server-launcher

# Install SaltyRTC server
RUN pip3 install saltyrtc.server[logging]

# Install cargo-audit
RUN cargo install cargo-audit

# Install splint
#
# Debian package seems broken, results in parse error.
# Build instructions taken from
# https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/splint
RUN cd /opt && \
    git clone https://repo.or.cz/splint-patched.git && \
    cd splint-patched && \
    $(automake --add-missing || true) && \
    $(autoreconf || true) && \
    automake --add-missing && \
    autoreconf && \
    ./configure --prefix=/usr --mandir=/usr/share/man && \
    make && \
    make install

# Export SaltyRTC test permanent key
ENV SALTYRTC_SERVER_PERMANENT_KEY=0919b266ce1855419e4066fc076b39855e728768e3afa773105edd2e37037c20
