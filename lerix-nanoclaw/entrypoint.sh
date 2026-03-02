#!/bin/bash
set -e

# Install ttyd and git on first run
if ! command -v ttyd &> /dev/null; then
  apt-get update && apt-get install -y ttyd git docker.io && rm -rf /var/lib/apt/lists/*
fi

# Clone and build NanoClaw on first run
if [ ! -f /data/nanoclaw/package.json ]; then
  echo "First run: cloning NanoClaw..."
  git clone --depth 1 https://github.com/qwibitai/NanoClaw.git /data/nanoclaw
  cd /data/nanoclaw
  npm ci
  npm run build
else
  cd /data/nanoclaw
fi

# Write .env file
cat > /data/nanoclaw/.env <<ENVEOF
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
CLAUDE_CODE_OAUTH_TOKEN=${CLAUDE_CODE_OAUTH_TOKEN}
ASSISTANT_NAME=${ASSISTANT_NAME:-Andy}
CONTAINER_IMAGE=${CONTAINER_IMAGE:-nanoclaw-agent:latest}
TZ=${TZ:-UTC}
ENVEOF

# Build agent container image if Docker is available
if docker info &> /dev/null 2>&1; then
  if ! docker image inspect nanoclaw-agent:latest &> /dev/null 2>&1; then
    echo "Building NanoClaw agent container image..."
    cd /data/nanoclaw/container && docker build -t nanoclaw-agent:latest . 2>&1 || echo "Warning: Could not build agent image"
    cd /data/nanoclaw
  fi
fi

# Start NanoClaw inside ttyd for web terminal access
exec ttyd --port 7681 --writable node /data/nanoclaw/dist/index.js
