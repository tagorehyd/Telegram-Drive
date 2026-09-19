# Docker Web UI

Telegram Drive's Docker distribution is a **single Web UI container**. It
builds the existing React/Vite interface and serves it through an unprivileged
NGINX process on port `8080`. It does not start the Cloudflare supporter worker,
an API relay, a database, or any other sidecar.

## Start

```bash
docker compose up --build -d
```

Open `http://localhost:8080`. To use a different host port, set
`TELEGRAM_DRIVE_WEBUI_PORT`, for example:

```bash
TELEGRAM_DRIVE_WEBUI_PORT=3000 docker compose up --build -d
```

Verify the running service and stop it when finished:

```bash
curl --fail http://localhost:8080/healthz
docker compose ps
docker compose down
```

## Scope and security

The service is intentionally UI-only: its filesystem is read-only, it runs as
the image's unprivileged NGINX user, has no Linux capabilities, and accepts no
secrets or persistent volumes. It also exposes no backend API or proxy route.

Telegram Drive's current authenticated file operations, encrypted vault,
desktop sync, local REST/WebDAV, native downloads, tray, and native media
facilities are implemented by the Tauri native application. A browser-only
container cannot safely provide those device-bound capabilities or preserve the
native secure-storage and lifetime-supporter entitlement contract. Use the
native desktop application for those operations; this container packages the
same Web UI only and does not alter supporter services or existing purchasers'
entitlements.

## Production deployment

Place a TLS-terminating reverse proxy in front of port `8080` and do not expose
the container directly to the public Internet without appropriate access
controls. The container includes a `GET /healthz` endpoint for readiness and
liveness checks. Rebuild and redeploy after updating the repository:

```bash
docker compose build --pull webui
docker compose up -d --force-recreate webui
```
