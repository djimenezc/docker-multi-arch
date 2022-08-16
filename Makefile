
docker-build-builder:
	docker buildx create --name mybuilder --driver-opt network=host --use
	docker buildx inspect --bootstrap

docker-destroy-builder:
	docker buildx rm mybuilder

docker-build-multi-arch:
	docker buildx build \
    --push \
    --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
    --tag djimenezc/multiarch-example:buildx-latest .

podman-build-multi-arch:
	podman buildx build \
	--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
	--tag djimenezc/multiarch-example:buildx-latest .
