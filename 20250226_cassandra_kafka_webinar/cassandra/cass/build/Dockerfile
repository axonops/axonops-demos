FROM docker.io/eclipse-temurin:11.0.26_4-jre

RUN cat /etc/os-release
RUN uname -r

ENV CASSANDRA_HOME /opt/cassandra
ENV CASSANDRA_CONF /opt/cassandra/conf

# explicitly set user/group IDs
RUN set -eux; \
	groupadd -r cassandra --gid=999; \
	useradd -m -d "$CASSANDRA_HOME" -r -g cassandra --uid=999 cassandra


RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		openssh-server \
		libjemalloc2 \
		procps \
		python3 \
		iproute2 \
		numactl \
		webhook \
		gawk \
		grep \
		vim \
		dstat \
		jq \
		ca-certificates \
		gnupg \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*; \
# https://issues.apache.org/jira/browse/CASSANDRA-15767 ("bin/cassandra" only looks for "libjemalloc.so" or "libjemalloc.so.1" which doesn't match our "libjemalloc.so.2")
	libjemalloc="$(readlink -e /usr/lib/*/libjemalloc.so.2)"; \
	ln -sT "$libjemalloc" /usr/local/lib/libjemalloc.so; \
	ldconfig

# Create the SSH runtime directory
RUN mkdir /var/run/sshd

# Set the root password (change 'rootpassword' to a secure password in production)
RUN echo 'root:rootpassword' | chpasswd

# Update the SSH configuration to permit root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.17
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates gnupg wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true


ENV PATH $CASSANDRA_HOME/bin:$PATH

ENV CASSANDRA_VERSION 5.0.3
ENV TARBALL apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz

COPY files/${TARBALL} /${TARBALL}

RUN set -eux; \
    tar -C "$CASSANDRA_HOME" --strip-components=1 -xzf /${TARBALL}; \
    rm /${TARBALL}; \
	mkdir -p /var/lib/cassandra /var/log/cassandra /var/log/webook /var/webhook; \
	chown -R cassandra:cassandra "$CASSANDRA_HOME" /var/lib/cassandra /var/log/webook /var/log/cassandra /var/webhook; \
	chmod 777 "$CASSANDRA_CONF" /var/lib/cassandra /var/log/webook /var/log/cassandra /var/webhook; \
	ln -sT /var/lib/cassandra "$CASSANDRA_HOME/data"; \
	ln -sT /var/log/cassandra "$CASSANDRA_HOME/logs"; \
	\
# smoke test
	cassandra -v

VOLUME /var/lib/cassandra

COPY files/isrepairrunning.sh /usr/local/bin/
COPY files/repairnode.sh /usr/local/bin/
COPY files/_stop_cassandra.sh /usr/local/bin/
COPY files/_kill_cassandra.sh /usr/local/bin/
COPY files/repaircluster.sh /usr/local/bin/
COPY files/waitforit.sh /usr/local/bin/
COPY files/repaircluster.sh /usr/local/bin/
COPY files/setupcassandradata.sh /usr/local/bin/
COPY files/startssh.sh /usr/local/bin/
COPY files/startwebhooks.sh /usr/local/bin/
COPY files/startcassandra.sh /usr/local/bin/
COPY files/stopcassandra.sh /usr/local/bin/
COPY files/killcassandra.sh /usr/local/bin/
COPY files/tailcassandralogs.sh /usr/local/bin/
COPY files/hooks.json /var/webhook
COPY files/nodetooldescribecluster.sh /usr/local/bin/
COPY files/nodetooldisablebinary.sh /usr/local/bin/
COPY files/nodetooldisablegossip.sh /usr/local/bin/
COPY files/nodetooldisablehandoff.sh /usr/local/bin/
COPY files/nodetooldisablehintsforalpha.sh /usr/local/bin/
COPY files/nodetooldisablehintsforomega.sh /usr/local/bin/
COPY files/nodetoolenablebinary.sh /usr/local/bin/
COPY files/nodetoolenablegossip.sh /usr/local/bin/
COPY files/nodetoolenablehandoff.sh /usr/local/bin/
COPY files/nodetoolenablehintsforalpha.sh /usr/local/bin/
COPY files/nodetoolenablehintsforomega.sh /usr/local/bin/
COPY files/nodetoolgossipinfo.sh /usr/local/bin/
COPY files/nodetoolinfo.sh /usr/local/bin/
COPY files/nodetoolstatus.sh /usr/local/bin/
COPY files/waitforcassandratostart.sh /usr/local/bin/
COPY files/checkcassandrastable.sh /usr/local/bin/
COPY files/repairtarget.sh /usr/local/bin/

COPY files/cqlshrc /

RUN set -eux; \
    chmod 777 /usr/local/bin/isrepairrunning.sh; \
    chmod 777 /usr/local/bin/repairnode.sh; \
    chmod 777 /usr/local/bin/_kill_cassandra.sh; \
    chmod 777 /usr/local/bin/_stop_cassandra.sh; \
    chmod 777 /usr/local/bin/waitforit.sh; \
	chmod 777 /usr/local/bin/repaircluster.sh; \
	chmod 777 /usr/local/bin/setupcassandradata.sh; \
	chmod 777 /usr/local/bin/startssh.sh; \
	chmod 777 /usr/local/bin/startwebhooks.sh; \
	chmod 777 /usr/local/bin/startcassandra.sh; \
	chmod 777 /usr/local/bin/stopcassandra.sh; \
	chmod 777 /usr/local/bin/killcassandra.sh; \
	chmod 777 /usr/local/bin/tailcassandralogs.sh; \
	chmod 777 /usr/local/bin/nodetooldescribecluster.sh; \
	chmod 777 /usr/local/bin/nodetooldisablebinary.sh; \
	chmod 777 /usr/local/bin/nodetooldisablegossip.sh; \
	chmod 777 /usr/local/bin/nodetooldisablehandoff.sh; \
	chmod 777 /usr/local/bin/nodetooldisablehintsforalpha.sh; \
	chmod 777 /usr/local/bin/nodetooldisablehintsforomega.sh; \
	chmod 777 /usr/local/bin/nodetoolenablebinary.sh; \
	chmod 777 /usr/local/bin/nodetoolenablegossip.sh; \
	chmod 777 /usr/local/bin/nodetoolenablehandoff.sh; \
	chmod 777 /usr/local/bin/nodetoolenablehintsforalpha.sh; \
	chmod 777 /usr/local/bin/nodetoolenablehintsforomega.sh; \
	chmod 777 /usr/local/bin/nodetoolgossipinfo.sh; \
	chmod 777 /usr/local/bin/nodetoolinfo.sh; \
	chmod 777 /usr/local/bin/nodetoolstatus.sh; \
	chmod 777 /usr/local/bin/waitforcassandratostart.sh; \
	chmod 777 /usr/local/bin/repairtarget.sh; \
	chmod 777 /usr/local/bin/checkcassandrastable.sh; \
	chmod -R 777 /var/webhook;

USER cassandra

ENV LOCAL_JMX no

# 22: ssh
# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9142: CQL over SSL (if enabled on seperate port)
# 9000: Web Hook Port
EXPOSE 22 7000 7001 7199 9042 9142 9000