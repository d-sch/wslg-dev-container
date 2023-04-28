FROM ubuntu:22.10 as runtime

ARG S6_OVERLAY_VERSION=3.1.4.1
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_CUSTOM_PKG
# Uncomment the lines below to use a 3rd party repository
# to get the latest (unstable from mesa/main) mesa library version
# RUN apt-get update && apt install -y software-properties-common
# RUN add-apt-repository ppa:oibaf/graphics-drivers -y

RUN apt update && apt --no-install-recommends --yes install software-properties-common gpg-agent \
&& rm -rf /var/lib/apt/lists/*
RUN printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' | tee /etc/apt/preferences.d/mozilla-firefox \
&& printf 'Package: firefox\nPin: version 1:1snap1-0ubuntu2\nPin-Priority: -1' | tee -a /etc/apt/preferences.d/mozilla-firefox \
&& printf 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
&& add-apt-repository --yes ppa:mozillateam/ppa \
&& apt update && apt install --no-install-recommends --yes \
vainfo mesa-va-drivers firefox \
${APT_CUSTOM_PKG} \
&& rm -rf /var/lib/apt/lists/*

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

COPY ./context/ ./

ENTRYPOINT ["/init"]