# myutils

Utility scripts in this directory:

- `gencert.sh`: generate a local self-signed certificate and key under `.cert/`
- `enablePort.sh`: open a firewall port in the `public` zone and reload `firewalld`

## gencert.sh

Creates:

- `.cert/selfsigned.crt`
- `.cert/selfsigned.key`

Defaults:

- `DAYS=365`
- `CN=localhost`
- `FORCE=0`
- `VERBOSE=0`

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

Notes:

- Requires `openssl`
- If the certificate or key already exists, the script exits without replacing them unless `FORCE=1`
- The private key is written with `600` permissions and the certificate with `644`

## enablePort.sh

Enables a port permanently in the `public` zone using `firewall-cmd`, then reloads the firewall.

Defaults:

- Port `443`
- Protocol `tcp`

Usage:

```bash
./enablePort.sh
```

```bash
./enablePort.sh 8443
./enablePort.sh 53/udp
```

Notes:

- Requires `firewall-cmd`
- Uses `sudo` automatically when not run as root
- Accepts `port` or `port/protocol`
- Supported protocols are `tcp` and `udp`
