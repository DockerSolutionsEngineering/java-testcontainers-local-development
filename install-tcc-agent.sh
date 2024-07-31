#!/usr/bin/env sh
# (C) AtomicJar, Inc. 2022-present
# All rights reserved
# Testcontainers Cloud Agent installation script: install and set up the Agent on supported nix distributions

set -e

b="\033[0;36m"
g="\033[0;32m"
r="\033[0;31m"
e="\033[0;90m"
x="\033[0m"

say() {
  echo "$1"
}

#----------------------------------------
# Configuration options available
#----------------------------------------

# Binary name - relative to the current working directory name of the binary to install
TCC_BINARY_NAME=${TCC_BINARY_NAME:-"tcc-agent"}

# If you want to fully control the agent lifecycle yourself, set this to true
TCC_SKIP_AGENT_EXECUTION=${TCC_SKIP_AGENT_EXECUTION:-""}

# Debug logging environment variable recognized by the agent natively
#TC_CLOUD_LOGS_VERBOSE=

# ---------------------------------------


say "${e}
Installing Testcontainers Cloud Agent...
${x}"

# determine the os for the agent
platform="$(uname -s)"
case "${platform}" in
    Linux*)     OS_TYPE=linux;;
    Darwin*)    OS_TYPE=darwin;;
    *)          say "${r}This script doesn't know how to deal with${x} ${platform} ${r}os type!${x}"; exit 1
esac

# determine the architecture of the platform
arch="$(uname -m)"
case "${arch}" in
    aarch64*)  ARCH_TYPE=arm64;;
    arm64*)    ARCH_TYPE=arm64;;
    *)         ARCH_TYPE=x86-64;;
esac

LATEST_BINARY_URL="https://app.testcontainers.cloud/download/testcontainers-cloud-agent_${OS_TYPE}_${ARCH_TYPE}"

echo "Downloading ${LATEST_BINARY_URL}"
curl -fsSL -o "${TCC_BINARY_NAME}" ${LATEST_BINARY_URL}
chmod +x "${TCC_BINARY_NAME}"

VERSION=$(./"${TCC_BINARY_NAME}" --help 2>&1 | head -n 1 | cut -d'=' -f3-)

say "
${g}SUCCESSFULLY DOWNLOADED!${x}
${e}Version: $VERSION${x}
"

how_to_run_help() {
say "Now you can run ${b}${TCC_BINARY_NAME}${x} as a background process with the ${b}TC_CLOUD_TOKEN${x} environment variable specified:
    ${b}TC_CLOUD_TOKEN=<your service account token> nohup ./${TCC_BINARY_NAME} &${x}
"
}

if [ "$TCC_SKIP_AGENT_EXECUTION" ]; then
    exit 0
fi

if [ -z "$TC_CLOUD_TOKEN" ] && ! grep -q 'cloud.token' ~/.testcontainers.properties; then
    how_to_run_help
    exit 0
fi

say "Launching ${b}${TCC_BINARY_NAME}${x} with nohup..."
nohup ./"${TCC_BINARY_NAME}" > tcc-agent.log 2>&1 &