FROM debian:jessie

COPY files/sources.list /etc/apt/sources.list
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init

RUN groupadd zabbix && useradd -g zabbix zabbix && \
    chmod +x /usr/local/bin/dumb-init && \
    apt-get update && apt-get -y install --no-install-recommends fping tar gcc make postgresql curl \
    libssh2-1-dev libpq-dev libldap2-dev libiksemel-dev libopenipmi-dev unixodbc-dev libsnmp-dev snmp libpng-dev \ 
    libxml2-dev libgnutls28-dev libcurl4-gnutls-dev git nmap fping traceroute libldb-dev && \
    ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean 

WORKDIR /usr/src
ARG ZBX_VERSION=3.4.0
RUN curl -L --output /usr/src/zabbix.tar.gz http://ufpr.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/${ZBX_VERSION}/zabbix-${ZBX_VERSION}.tar.gz
RUN git clone -c http.SslVerify=False https://github.com/meduketto/iksemel.git && \
    tar xzvf zabbix.tar.gz && \
    cd /usr/src/zabbix-$ZBX_VERSION && \
    ./configure --enable-server --enable-agent --with-postgresql \
    --with-net-snmp --with-libcurl --with-openipmi --with-gnutls \
    --with-ldap --with-libcurl --with-ssh2 --with-unixodbc \
    --with-jabber=/usr/src/iksemel --with-libxml2 && make -j && make install -j && \
    rm -rf /usr/src/*

RUN chown -R zabbix:zabbix /usr/local/etc/zabbix_server.conf.d && \
    echo "Include=/usr/local/etc/zabbix_server.conf.d/" > /usr/local/etc/zabbix_server.conf && \
    ln -s /usr/bin/fping /usr/sbin/fping

EXPOSE 10051

COPY files/docker-entrypoint.sh /

USER zabbix
ENTRYPOINT ["/usr/local/bin/dumb-init","/docker-entrypoint.sh"]

