# Docker build with full attestation and SBOM carryover:
docker build -t democbarker/demoattest:uv -f uv.Dockerfile \
    --platform linux/arm64,linux/amd64 --sbom=true --provenance=mode=max \
    --pull --push .
