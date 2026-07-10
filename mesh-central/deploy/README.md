# MeshCentral Deploy Assets

This folder mirrors the NPM deploy volume on `cilate`:

- `/home/dietpi/docker_data/NPM/deploy/install.ps1` on the server
- `https://meshc.alsd.duckdns.org/install.ps1` over the public proxy host

We can SSH into `cilate` and compare the live file against this mirror whenever the bootstrap script changes.

The Windows bootstrap command is:

```powershell
irm https://meshc.alsd.duckdns.org/install.ps1 | iex
```

The matching NPM advanced block lives in [`../NPM-extraconf.conf`](../NPM-extraconf.conf).

Together, the advanced block and this script define the canonical MeshCentral access path:

- advanced block = routing, auth, and proxy behavior
- `install.ps1` = Windows agent bootstrap only

When the server copy changes, keep this mirror updated so the bootstrap path and the proxy config stay in sync.
