
# Simple example repo for attestation

docker-bake.hcl is a complicated way to make two different images, attestation-pip and attestation-vi, that include sbom, attestations, and will push to the upstream repo.

One of the benefits of using docker-bake.hcl is you can do some common variable lookups, in this case defining the SHA's to use for the images, so you can have a consistent way to ensure that the `org.opencontainers.image.base.digest` is being set along with the.

If you wanted to update this build to use different SHAs, you could use regctl to get the index sha, and then perform the bake, which will push the images up to `${BASEURL}/attestion-{vi,pip}:tag` for you (local docker registry doesn't support attestations, so to use them you must push it to a repo):
```shell
export TAG=$(git rev-parse --short HEAD)
export BASEURL="docker.io/democbarker"
export RUNSHA="$(regctl manifest head ${BASEURL}/dhi-python:3.13)"
export DEVSHA="$(regctl manifest head ${BASEURL}/dhi-python:3.13-dev)"
docker bake
```


# Docker build with full attestation and SBOM carryover:

This is a simpler version that just builds the image

docker build -t democbarker/demoattest:uv -f uv.Dockerfile \
    --platform linux/arm64,linux/amd64 --sbom=true --provenance=mode=max \
    --pull --push .
