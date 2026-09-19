# syntax=docker/dockerfile:1

# Build the browser interface in a reproducible Node environment.  The lockfile
# is copied before source code so dependency installation remains cacheable.
FROM node:22-alpine AS build
WORKDIR /build/app

COPY app/package.json app/package-lock.json ./
RUN npm ci --ignore-scripts

COPY app/ ./
RUN npm run build:verify

# Serve only the compiled Web UI.  There is intentionally no privileged shell,
# package manager, development server, or native Tauri runtime in this image.
FROM nginxinc/nginx-unprivileged:1.28-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /build/app/dist /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
