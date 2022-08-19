
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

podman-build-amd64:
	podman buildx build \
	--build-arg ARM=amd64 \
	--platform=linux/amd64 \
	-t docker.io/djimenezc/multiarch-example:podman-buildx-latest .
	podman push docker.io/djimenezc/multiarch-example:podman

podman-build:
	podman build \
	--build-arg ARM=arm64 \
	-t docker.io/djimenezc/multiarch-example:podman .
	podman push docker.io/djimenezc/multiarch-example:podman

podman-curl-run:
	docker run djimenezc/multiarch-example:podman https://www.example.com
