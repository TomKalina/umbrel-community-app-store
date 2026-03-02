#!/bin/bash
set -e

# Write .env file from environment variables
cat > /app/.env <<ENVEOF
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
CLAUDE_CODE_OAUTH_TOKEN=${CLAUDE_CODE_OAUTH_TOKEN}
ASSISTANT_NAME=${ASSISTANT_NAME:-Andy}
CONTAINER_IMAGE=${CONTAINER_IMAGE:-nanoclaw-agent:latest}
TZ=${TZ:-UTC}
ENVEOF

# Build the agent container image if Docker is available
if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
  echo "Building NanoClaw agent container image..."
  cd /app/container && docker build -t nanoclaw-agent:latest . 2>&1 || echo "Warning: Could not build agent image"
  cd /app
fi

# Start NanoClaw inside ttyd so users can see QR code and logs via web browser
exec ttyd --port 7681 --writable node dist/index.js
