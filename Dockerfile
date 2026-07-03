FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      bash-completion \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      dnsutils \
      fd-find \
      file \
      fzf \
      gh \
      git \
      git-lfs \
      iproute2 \
      iputils-ping \
      jq \
      less \
      locales \
      lsof \
      nano \
      net-tools \
      nodejs \
      npm \
      openssh-client \
      pkg-config \
      procps \
      psmisc \
      python3 \
      python3-pip \
      python3-venv \
      ripgrep \
      shellcheck \
      sudo \
      tree \
      tzdata \
      unzip \
      vim \
      wget \
      xz-utils \
      zip \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY entrypoint.sh /usr/local/bin/avibe-entrypoint
RUN chmod +x /usr/local/bin/avibe-entrypoint

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/avibe-entrypoint"]
CMD ["bash", "-l"]
