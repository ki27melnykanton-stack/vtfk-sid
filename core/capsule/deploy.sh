#!/usr/bin/env bash
set -euo pipefail

HOST_PORT=${HOST_PORT:-8082}
NAME=devbox-charlie

if ! [[ $HOST_PORT =~ ^[0-9]+$ ]] || (( HOST_PORT < 1 || HOST_PORT > 65535 )); then
  echo 'HOST_PORT має бути числом від 1 до 65535' >&2
  exit 2
fi

docker version >/dev/null
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" -p "${HOST_PORT}:80" ubuntu:24.04 sleep infinity >/dev/null
docker exec "$NAME" sh -c 'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl git procps iproute2 >/dev/null'

docker inspect -f '{{.State.Running}}' "$NAME" | grep -qx true
printf 'Контейнер %s працює; порт хоста %s -> порт контейнера 80\n' "$NAME" "$HOST_PORT"
