FROM debian:sid
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    devscripts pbuilder git-buildpackage bash-completion libcurl4-openssl-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
