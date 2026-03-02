# NanoClaw - Personal Claude Assistant for WhatsApp
# Builds from source with ttyd for web-based terminal access

FROM node:22-slim AS builder

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 https://github.com/qwibitai/NanoClaw.git .
RUN npm ci && npm run build

FROM node:22-slim

RUN apt-get update && apt-get install -y \
    ttyd \
    docker.io \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /build/dist ./dist
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/package.json ./
COPY --from=builder /build/groups ./groups
COPY --from=builder /build/container ./container

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

RUN mkdir -p /app/store /app/data

EXPOSE 7681

ENTRYPOINT ["/app/entrypoint.sh"]
