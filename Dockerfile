FROM ubuntu:24.10 as runtime

ARG S6_OVERLAY_VERSION=3.1.4.1
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_CUSTOM_PKG
# Uncomment the lines below to use a 3rd party repository
# to get the latest (unstable from mesa/main) mesa library version
# RUN apt-get update && apt install -y software-properties-common
# RUN add-apt-repository ppa:oibaf/graphics-drivers -y

RUN userdel -r ubuntu && apt update && apt --no-install-recommends --yes install software-properties-common gpg-agent wget \
&& rm -rf /var/lib/apt/lists/* \
&& wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
&& gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}' \
&& echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
&& printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 100\n' | tee /etc/apt/preferences.d/mozillateam \
&& printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' | tee -a /etc/apt/preferences.d/mozillateam \
&& printf 'Package: firefox*\nPin: release o=Ubuntu\nPin-Priority: -1\n' | tee -a /etc/apt/preferences.d/mozillateam \
&& printf 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
&& echo 'add-apt-repository --yes ppa:mozillateam/ppa' \
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
