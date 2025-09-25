FROM alpine:3.22

ARG TARGETARCH

RUN apk add --no-cache \
    aws-cli \
    bash \
    coreutils \
    curl \
    gawk \
    git \
    jq \
    yq \
    unzip \
    wget

# Set architecture variables once
RUN case "${TARGETARCH}" in \
        amd64) ARCH=amd64 ;; \
        arm64) ARCH=arm64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    \
    wget -O terraform.zip "https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_linux_${ARCH}.zip" && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    \
    wget -O /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v0.87.4/terragrunt_linux_${ARCH}" && \
    chmod +x /usr/local/bin/terragrunt && \
    \
    wget -O helm.tar.gz "https://get.helm.sh/helm-v3.19.0-linux-${ARCH}.tar.gz" && \
    tar -xzf helm.tar.gz && \
    mv linux-${ARCH}/helm /usr/local/bin/ && \
    rm -rf helm.tar.gz linux-${ARCH} && \
    \
    wget -O helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v1.1.7/helmfile_1.1.7_linux_${ARCH}.tar.gz" && \
    tar -xzf helmfile.tar.gz && \
    mv helmfile /usr/local/bin/ && \
    rm helmfile.tar.gz && \
    \
    helm version && \
    helmfile version && \
    kubectl version --client && \
    terraform --version && \
    terragrunt --version

WORKDIR /workspace
