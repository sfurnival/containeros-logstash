#!/usr/bin/bash

export HOME=/var/lib/logstash

: ${LS_LOG_LEVEL:=error}
: ${LS_HEAP_SIZE:=500m}
: ${LS_JAVA_OPTS:=-Djava.io.tmpdir=${HOME}}
: ${LS_LOG_DIR:=/var/lib/logstash}
: ${LS_OPEN_FILES:=8192}
: ${LS_PIPELINE_BATCH_SIZE:=125}

: ${ES_HOST:=127.0.0.1:9200}
: ${ES_USER:=""}
: ${ES_PASSWORD:=""}
: ${ES_HOST:=127.0.0.1:9200}
: ${ES_INDEX_SUFFIX:=""}
: ${ES_FLUSH_SIZE:=500}
: ${ES_IDLE_FLUSH_TIME:=1}

sed -e "s/%ES_HOST%/${ES_HOST}/" \
    -e "s/%ES_USER%/${ES_USER}/" \
    -e "s/%ES_PASSWORD%/${ES_PASSWORD}/" \
    -e "s/%ES_INDEX_SUFFIX%/${ES_INDEX_SUFFIX}/" \
    -e "s/%ES_FLUSH_SIZE%/${ES_FLUSH_SIZE}/" \
    -e "s/%ES_IDLE_FLUSH_TIME%/${ES_IDLE_FLUSH_TIME}/" \
    -i /logstash/conf.d/**/*.conf

ulimit -n ${LS_OPEN_FILES} > /dev/null

exec /logstash/bin/logstash --log.format json \
  --log.level ${LS_LOG_LEVEL} \
  --pipeline.batch.size ${LS_PIPELINE_BATCH_SIZE} \
  --config.reload.automatic \
  -f "/logstash/conf.d/logstash.conf" \
  ${LOGSTASH_ARGS}
