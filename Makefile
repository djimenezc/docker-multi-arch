
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

# PODMAN
podman-build-amd64:
	podman buildx build \
	--build-arg ARC=amd64 \
	--platform=linux/amd64 \
	-t docker.io/djimenezc/multiarch-example:podman .
	podman push docker.io/djimenezc/multiarch-example:podman

podman-build:
	podman build \
	--build-arg ARCH=arm64 \
	--platform=linux/arm64 \
	-t docker.io/djimenezc/multiarch-example:podman .
	podman push docker.io/djimenezc/multiarch-example:podman

podman-curl-run:
	podman run --rm djimenezc/multiarch-example:podman https://www.example.com

podman-get-arch-arm:
	podman run --rm --entrypoint=/usr/bin/arch \
	djimenezc/multiarch-example:podman

podman-get-arch-amd64:
	podman run --rm --platform linux/amd64 --entrypoint=/usr/bin/arch \
	djimenezc/multiarch-example:podman
