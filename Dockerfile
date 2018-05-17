FROM java:openjdk-8-jre

ARG kafka_version=1.1.0
ARG scala_version=2.11

MAINTAINER hklabs

ENV DEBIAN_FRONTEND=noninteractive \
    KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download-kafka.sh create-topics.sh /tmp/

ADD start-kafka.sh /usr/bin/start-kafka.sh

ADD supervisor/kafka.conf supervisor/zookeeper.conf /etc/supervisor/conf.d/

RUN apt-get update \
    && apt-get install -y bash zookeeper wget supervisor dnsutils net-tools jq curl \
    && chmod a+x /tmp/*.sh \
    && /tmp/download-kafka.sh \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

EXPOSE 2181 9092

CMD ["supervisord", "-n"]
