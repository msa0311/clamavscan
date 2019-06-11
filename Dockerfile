FROM debian:jessie

# Debian Base to use
ENV DEBIAN_VERSION jessie



# initial install of av daemon
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq \
        clamav-daemon \
        clamav-freshclam \
        curl \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install java
RUN echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-2 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-2 seen true | debconf-set-selections  && \
    echo "deb http://ppa.launchpad.net/linuxuprising/java/ubuntu bionic main" | tee /etc/apt/sources.list.d/linuxuprising-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EA8CACC073C3DB2A && \
    apt-get update  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java11-installer oracle-java11-set-default
RUN echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk11-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*



# add the spring clamav-rest service to container and define working directory
CMD mkdir /var/clamav-rest
COPY target/clamav-rest-1.0.2.jar /var/clamav-rest/
WORKDIR /var/clamav-rest/

# initial update of av databases
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd

# permission juggling
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

# av configuration update
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^StreamMaxLength .*$/StreamMaxLength 110M/g' /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 8080

# av daemon bootstrapping
ADD bootstrap.sh /
ADD testi.sh /
CMD ["/bootstrap.sh"]
