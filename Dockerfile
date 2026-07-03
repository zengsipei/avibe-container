FROM debian:trixie

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    FNM_DIR=/opt/fnm

ENV PATH="${FNM_DIR}:${PATH}"

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
      openssh-client \
      pkg-config \
      procps \
      psmisc \
      python3 \
      python3-pip \
      python3-venv \
      ripgrep \
      shellcheck \
      socat \
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

RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell \
    && eval "$("$FNM_DIR/fnm" env --shell bash)" \
    && fnm install --lts \
    && fnm default lts-latest \
    && fnm use lts-latest \
    && node --version \
    && npm --version \
    && { \
      echo 'export FNM_DIR=/opt/fnm'; \
      echo 'export PATH="$FNM_DIR:$PATH"'; \
      echo 'eval "$(fnm env --use-on-cd --shell bash)"'; \
    } > /etc/profile.d/fnm.sh

COPY entrypoint.sh /usr/local/bin/avibe-entrypoint
RUN chmod +x /usr/local/bin/avibe-entrypoint

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/avibe-entrypoint"]
CMD ["bash", "-l"]
