
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

podman-build-multi-arch:
	podman buildx build \
	--platform=linux/amd64 \
	-t docker.io/djimenezc/multiarch-example:podman-buildx-latest .
	podman push docker.io/djimenezc/multiarch-example:podman-buildx-latest

podman-build:
	podman build \
	--build-arg arm64 \
	-t docker.io/djimenezc/multiarch-example:podman .
	podman push docker.io/djimenezc/multiarch-example:podman

