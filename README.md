# containeros-logstash

[![Docker Repository on Quay.io](https://quay.io/repository/sfurnival/containeros-logstash/status "Docker Repository on Quay.io")](https://quay.io/repository/sfurnival/containeros-logstash)

Logstash container for shipping systemd journals to Elastic via Logstash.

(Major inspiration from: https://github.com/UKHomeOffice/docker-logstash-kubernetes)

## Requirements

For logstash to be able to pull logs from journal, you need to make sure that
logstash can read `/var/log/journal`.

Also, logstash writes `sincedb` file to its home directory, which by default is
`/var/lib/logstash`. If you don't want logstash to start reading docker or
journal logs from the beginning after a restart, make sure you mount
`/var/lib/logstash` somewhere on the host.

## Configuration

As usual, configuration is passed through environment variables.

- `LS_HEAP_SIZE` - logstash JVM heap size. Defaults to `500m`.
- `LS_LOG_LEVEL` - Logstash log level. Default: `error`.
- `LS_PIPELINE_BATCH_SIZE` - Size of batches the pipeline is to work in. Default: `125`
- `ES_FLUSH_SIZE` - Bulk index flush size. Default: `500`
- `ES_IDLE_FLUSH_TIME` - Bulk index idle flush time in seconds. Default: `1`
- `ES_HOST` - ElasticSearch host, can be comma separated. Default: `127.0.0.1:9200`.
- `ES_INDEX_SUFFIX` - ElasticSearch index suffix. Default: `""`.
- `LOGSTASH_ARGS` - Sets additional logstash command line arguments.


## Running

```
$ docker run -ti --rm \
    -v /var/lib/logstash:/var/lib/logstash \
    -v /var/log/journal:/var/log/journal:ro \
    -e ES_HOST=<your elastic host>:9200 \
    -e ES_USER=<username> \
    -e ES_PASSWORD=<your password> \
    quay.io/sfurnival/containeros-logstash:latest
```

### Via Fleet

Usually you'll want to manage the lifecycle of the logstash service using
[fleet](https://github.com/coreos/fleet). To do so, you can create a service
file similar to this example:

**`logstash.service`**

``` ini
[Unit]
Description=Logstash Service

[Service]
User=core
Restart=on-failure
TimeoutStartSec=0

ExecStartPre=-/usr/bin/docker kill logstash
ExecStartPre=-/usr/bin/docker rm logstash
ExecStartPre=/usr/bin/docker pull quay.io/sfurnival/containeros-logstash:latest

ExecStart=/usr/bin/docker run \
    --name logstash \
    -v /var/lib/logstash:/var/lib/logstash \
    -v /var/log/journal:/var/log/journal:ro \
    -e ES_HOST='<your elastic host>' \
    -e ES_USER=<username> \
    -e ES_PASSWORD=<your password> \
    quay.io/sfurnival/containeros-logstash:latest

ExecStop=/usr/bin/docker stop logstash

[X-Fleet]
Global=true
```