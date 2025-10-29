variable "TAG" {
    default = "latest"
}

variable "VERSION" {
    default = "0.1.0"
}

variable "DEVSHA" {
    default = "sha256:8618da1bf0111e2050d3a22484ccf7cde5c5ea0dbe4e45f7184584e21bbb508e"
}

variable "RUNSHA" {
    default = "sha256:1efb666ab69200d7aa5516143190d82a3d171177b655a43b708c9ee0878eb1c5"
}

variable "BASEURL" {
    default = "docker.io/democbarker"
}

group "default" {
    targets = ["uv", "pip"]
}

target "base" {
    context = "."
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64", "linux/arm64"]
    pull = true
    output = [{ type = "registry" }]
    args = {
        DEVSHA = "@${DEVSHA}"
        RUNSHA = "@${RUNSHA}"
        BASEURL = "${BASEURL}"
    }
    labels = {
        "org.opencontainers.image.base.name"    = "${BASEURL}/dhi-python:3.13",
        "org.opencontainers.image.base.digest"  = "${BASEURL}/dhi-python:3.13@${RUNSHA}"
    }
    attest = [
        {
            type = "provenance"
            mode = "max"
        },
        {
            type = "sbom"
        }
    ]
}

target "uv" {
    inherits = ["base"]
    target = "uv-runtime-stage"
    tags = ["${BASEURL}/attestation-vi:${VERSION}-${TAG}"]
}

target "pip" {
    inherits = ["base"]
    target = "pip-runtime-stage"
    tags = ["${BASEURL}/attestation-pip:${VERSION}-${TAG}"]
}