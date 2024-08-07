#!/bin/bash
set -ex

CSB_VERSION="v0.22.2"
SMTP_BROKERPAK_VERSION="v2.0.0"

# Set up an app dir and bin dir
mkdir -p app-smtp/bin

# Generate a .profile to be run at startup for mapping VCAP_SERVICES to needed
# environment variables
cat > app-smtp/.profile << 'EOF'
# Locate additional binaries needed by the deployed brokerpaks
export PATH="$PATH:${PWD}/bin"
EOF
chmod +x app-smtp/.profile

# Add the cloud-service-broker binary
(cd app-smtp && curl -f -L -o cloud-service-broker https://github.com/cloudfoundry/cloud-service-broker/releases/download/${CSB_VERSION}/cloud-service-broker.linux) && \
    chmod +x app-smtp/cloud-service-broker

# Add the brokerpak(s)
(cd app-smtp && curl -f -LO https://github.com/GSA-TTS/datagov-brokerpak-smtp/releases/download/${SMTP_BROKERPAK_VERSION}/datagov-brokerpak-smtp-${SMTP_BROKERPAK_VERSION}.brokerpak)
