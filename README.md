# myutils

Utility scripts in this directory:

- `gencert.sh`: generate a local self-signed certificate and key under `.cert/`
- `enablePort.sh`: open a firewall port in the `public` zone and reload `firewalld`
- `OL8/install_mysql_shell_innovation.sh`: install `mysql-shell` from MySQL Innovation repos on Oracle Linux 8
- `OL9/install_mysql_shell_innovation.sh`: install `mysql-shell` from MySQL Innovation repos on Oracle Linux 9

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

## Oracle Linux MySQL Shell installers

Two version-specific installers are included:

- `OL8/install_mysql_shell_innovation.sh`
- `OL9/install_mysql_shell_innovation.sh`

Prerequisites:

- Oracle Linux 8 for the `OL8` installer, or Oracle Linux 9 for the `OL9` installer
- `dnf`
- Root access or `sudo`
- Network access to `repo.mysql.com`

What they do:

- Install the matching MySQL Yum repository RPM for the platform
- Install `dnf-plugins-core` if needed for `dnf config-manager`
- Disable the default LTS/community MySQL repos
- Enable the MySQL Innovation server and tools repos
- Install `mysql-shell`

Oracle Linux 8 usage:

```bash
./OL8/install_mysql_shell_innovation.sh
```

Oracle Linux 9 usage:

```bash
./OL9/install_mysql_shell_innovation.sh
```

Notes:

- The OL8 installer also disables the default `mysql` DNF module because EL8-based systems mask MySQL repository packages unless that module is disabled
- Each script validates the detected major OS version and exits if used on the wrong platform
- Each installer chooses `sudo` automatically when not run as `root`
