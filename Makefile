export PLATFORM_ARCH=linux/amd64,linux/arm64

docker-build-builder:
	docker buildx create --name mybuilder --driver-opt network=host --use
	docker buildx inspect --bootstrap
	$(MAKE) docker-install-qemu-emulator
	$(MAKE) docker-build-ls

docker-install-qemu-emulator:
	docker run -it --rm --privileged tonistiigi/binfmt --install all

docker-build-ls:
	docker buildx ls

docker-destroy-builder:
	docker buildx rm mybuilder

docker-build-multi-arch:
	docker buildx build \
	--builder=mybuilder \
	--push \
    --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
    -t djimenezc/multiarch-example:buildx-latest .

# Testing docker images
docker-get-arch-multiarch-with-docker:
	docker run --rm --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:buildx-latest
	docker run --rm --platform linux/arm64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:buildx-latest
	docker run --rm --platform linux/amd64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:buildx-latest

# PODMAN
podman-build-amd64:
	podman buildx build \
	--platform=linux/amd64 \
	-t docker.io/djimenezc/multiarch-example:podman-amd64 .
	podman push docker.io/djimenezc/multiarch-example:podman-amd64

podman-build:
	podman build \
	--platform=linux/arm64 \
	-t docker.io/djimenezc/multiarch-example:podman-arm64 .
	podman push docker.io/djimenezc/multiarch-example:podman-arm64

podman-build-multi-arch:
	buildah build --jobs=2 --platform=${PLATFORM_ARCH} --manifest shazam .
	skopeo inspect --raw containers-storage:localhost/shazam | \
          jq '.manifests[].platform.architecture'
	buildah tag localhost/shazam docker.io/djimenezc/multiarch-example:podman-multiarch
	buildah manifest rm localhost/shazam
	buildah manifest push --all docker.io/djimenezc/multiarch-example:podman-multiarch docker://docker.io/djimenezc/multiarch-example:podman-multiarch

# Testing podman images

podman-curl-run:
	podman run --rm docker.io/djimenezc/multiarch-example:podman-multiarch https://www.example.com

podman-get-arch-arm64:
	podman run --rm --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-arm64

podman-get-arch-amd64:
	podman run --rm --platform linux/amd64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-amd64

podman-get-arch-multiarch:
	podman run --rm --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-multiarch
	podman run --rm --platform linux/arm64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-multiarch
	podman run --rm --platform linux/amd64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-multiarch

podman-get-arch-multiarch-with-docker:
	docker run --rm --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-multiarch
	docker run --rm --platform linux/arm64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-multiarch
	docker run --rm --platform linux/amd64 --entrypoint=/usr/bin/arch docker.io/djimenezc/multiarch-example:podman-multiarch
