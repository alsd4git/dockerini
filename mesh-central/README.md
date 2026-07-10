# MeshCentral Stack

Remote device management and remote-access gateway for your homelab.

## Features

- **Remote access**: central web UI for managing remote devices and sessions.
- **Reverse-proxy friendly**: attached to `npm_network` for published access.
- **Persistent storage**: data, files, backups, and web assets live under the configured data root.
- **Deploy bridge**: the NPM host serves `install.ps1` from the deploy volume so Windows agents can bootstrap with `irm https://meshc.alsd.duckdns.org/install.ps1 | iex`.

## Configuration

### Environment Variables

Copy the example file to `.env`, then set the data root:

```bash
cp .env.example .env
```

Key variables:

- `DOCKER_DATA_BASEFOLDER`

## Deploy Bridge

The MeshCentral proxy host in Nginx Proxy Manager uses the advanced config stored in [`NPM-extraconf.conf`](./NPM-extraconf.conf). The install script that NPM serves at `/install.ps1` is mirrored in [`deploy/install.ps1`](./deploy/install.ps1).

We also have SSH access to `cilate`, so we can compare the live files on the machine against the local mirror whenever we need to verify or refresh them.

If you update the server-side script under `/home/dietpi/docker_data/NPM/deploy/install.ps1`, copy the same change here so the local backup stays in sync.

The intended relationship is:

- NPM advanced config: canonical routing/auth layer
- `install.ps1`: thin Windows bootstrapper
- local mirror: backup and diff target for the live files on `cilate`

## Services & Ports

| Service | External Port | Internal Ports | Notes |
| --- | --- | --- | --- |
| MeshCentral | `87` | `80`, `443`, `4433` | HTTPS mapping on the host, with internal ports exposed for reverse proxy and service traffic. |

## Container Images

| Service | Image |
| --- | --- |
| MeshCentral | `ghcr.io/ylianst/meshcentral:latest` |

## Usage

1. Copy `.env.example` to `.env`.
2. Set `DOCKER_DATA_BASEFOLDER`.
3. Start the stack:

   ```bash
   docker compose up -d
   ```

## Security Notes

- Keep the stack on a trusted network if you publish the admin UI.
- MeshCentral should be accessed through Nginx Proxy Manager or a similar reverse proxy.

## Additional Resources

- [MeshCentral Documentation](https://meshcentral.com/info/)
- [MeshCentral GitHub](https://github.com/Ylianst/MeshCentral)
