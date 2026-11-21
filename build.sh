#!/usr/bin/env bash
# Made by Sinfallas <sinfallas@yahoo.com>
# Licence: GPL-2

if [[ "$EUID" = "0" ]]; then
	echo -e "\e[00;31mERROR: NO debe ser root.\e[00m"
	exit 1
fi

CURRENT_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --name container-builder --driver docker-container --bootstrap --use
docker buildx build --platform linux/amd64 --build-arg BUILD_DATE=$CURRENT_DATE  --push -t sinfallas/flutter-builder:latest --builder=container-builder -f Dockerfile .

echo "finalizado..."
exit 0
