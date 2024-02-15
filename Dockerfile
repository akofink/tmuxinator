#
# docker build -t tmuxinator-dev --build-arg TMUX_VERSION=3.1 --build-arg RUBY_VERSION=3.2 .
#
# docker run -itv $HOME/.config/tmuxinator:/home/dev/.config/tmuxinator tmuxinator-dev
#
ARG RUBY_VERSION=3.0.1

FROM ruby:$RUBY_VERSION

ARG TMUX_VERSION=3.4

RUN \
  apt-get update \
  && apt-get install -y \
    autoconf \
    automake \
    bison \
    build-essential \
    git \
    libevent-dev \
    libncurses-dev \
    locales \
    pkg-config \
    sudo \
    vim \
  && rm -rf /var/lib/apt/lists/*

RUN \
  sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen \
  && git clone https://github.com/tmux/tmux.git tmux \
  && cd tmux \
  && git checkout $TMUX_VERSION \
  && bash autogen.sh \
  && bash ./configure \
  && make \
  && make install

ARG USER=dev
ARG UID=1000
ARG GID=1000
RUN \
  groupadd -g $GID $USER \
  && useradd -u $UID -g $GID -m $USER \
  && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER

WORKDIR /opt/app

ENV EDITOR=vim
ENV SHELL=/bin/bash

COPY --chown=$USER:$USER . .

RUN bundle install

ENTRYPOINT ["/usr/local/bin/bundle", "exec", "tmuxinator"]

USER $USER
