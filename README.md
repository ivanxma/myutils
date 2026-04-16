# myutils

Small shell utilities for local TLS setup, firewall changes, `systemd` service creation, and installing MySQL Shell from MySQL Innovation repositories on Oracle Linux.

## Scripts

| Script | Purpose |
| --- | --- |
| `gencert.sh` | Create a self-signed certificate and key in `.cert/` |
| `enablePort.sh` | Open a firewall port in the `public` zone with `firewalld` |
| `genservice.sh` | Create a `systemd` unit for an executable script |
| `OL8/install_mysql_shell_innovation.sh` | Install `mysql-shell` on Oracle Linux 8 from MySQL Innovation repos |
| `OL9/install_mysql_shell_innovation.sh` | Install `mysql-shell` on Oracle Linux 9 from MySQL Innovation repos |

## Requirements

- Bash
- `openssl` for `gencert.sh`
- `firewall-cmd` for `enablePort.sh`
- `systemctl` for `genservice.sh`
- `dnf` for the Oracle Linux installers
- `sudo` when not running as `root` for scripts that change system state

## gencert.sh

Creates a self-signed certificate and private key under the repository-local `.cert/` directory.

Files created:

- `.cert/selfsigned.crt`
- `.cert/selfsigned.key`

Environment variables:

- `DAYS` defaults to `365`
- `CN` defaults to `localhost`
- `FORCE` defaults to `0`
- `VERBOSE` defaults to `0`

Usage:

```bash
./gencert.sh
```

Examples:

```bash
CN=example.com DAYS=825 ./gencert.sh
FORCE=1 ./gencert.sh
VERBOSE=1 ./gencert.sh
```

Behavior:

- Exits without replacing existing files unless `FORCE=1`
- Writes the key with mode `600`
- Writes the certificate with mode `644`
- Suppresses `openssl` output unless `VERBOSE=1`

## enablePort.sh

Enables a port permanently in the `public` firewalld zone, then reloads the firewall.

Usage:

```bash
./enablePort.sh [port|port/protocol]
```

Examples:

```bash
./enablePort.sh
./enablePort.sh 8443
./enablePort.sh 53/udp
```

Behavior:

- Defaults to `443/tcp`
- Accepts either `port` or `port/protocol`
- Validates that the port is between `1` and `65535`
- Supports only `tcp` and `udp`
- Uses `sudo` automatically when not run as `root`
- Detects when the rule already exists before reloading

## genservice.sh

Creates a `systemd` unit in `/etc/systemd/system`, points `ExecStart` at a target executable, sets the service user, and runs `systemctl daemon-reload`.

Usage:

```bash
./genservice.sh <service-name> <runscript> <user>
```

Examples:

```bash
./genservice.sh myapp /opt/myapp/run.sh opc
./genservice.sh myapp.service ./run-local.sh "$(whoami)"
FORCE=1 ./genservice.sh myapp /opt/myapp/run.sh opc
```

Behavior:

- Rejects service names containing whitespace or `/`
- Accepts service names with or without the `.service` suffix
- Resolves relative script paths to absolute paths
- Requires the target user to exist
- Requires the run script to exist and be executable
- Refuses to overwrite an existing unit unless `FORCE=1`
- Uses `sudo` automatically when not run as `root`
- Does not enable or start the service automatically

Generated unit settings:

- `Type=simple`
- `After=network.target`
- `Restart=on-failure`
- `RestartSec=5`
- `WantedBy=multi-user.target`

## Oracle Linux MySQL Shell installers

Two OS-specific installers are included:

- `OL8/install_mysql_shell_innovation.sh`
- `OL9/install_mysql_shell_innovation.sh`

They install `mysql-shell` from MySQL Innovation repositories after switching the relevant MySQL repositories away from LTS/community defaults.

Common behavior:

- Verifies the detected major OS version before making changes
- Installs `dnf-plugins-core`
- Installs the matching MySQL repository RPM from `repo.mysql.com`
- Disables:
  - `mysql-8.4-lts-community`
  - `mysql-tools-8.4-lts-community`
  - `mysql80-community`
  - `mysql-tools-community`
- Enables:
  - `mysql-innovation-community`
  - `mysql-tools-innovation-community`
- Runs `dnf clean all`
- Installs `mysql-shell`
- Uses `sudo` automatically when not run as `root`

Oracle Linux 8 only:

- Also disables the default `mysql` DNF module before package installation

Usage:

```bash
./OL8/install_mysql_shell_innovation.sh
./OL9/install_mysql_shell_innovation.sh
```

Notes:

- Run the `OL8` installer only on Oracle Linux 8
- Run the `OL9` installer only on Oracle Linux 9
- Network access to `repo.mysql.com` is required
