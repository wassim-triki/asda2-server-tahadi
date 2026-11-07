# Asda 2 Tahadi Server

A WCell-based private server for **Asda 2 (Tahadi)**.

The server is experimental but playable. Login, characters, movement, combat, loot, inventory, persistence, and multiplayer have been tested. Some systems, including quests, remain incomplete.

The game client is not included.

## Getting started

The Windows release lets you host a server without building from source.

### Requirements

- Windows with .NET Framework 4.0 or a compatible later .NET Framework version.
- MySQL 5.7, either through Docker Compose (recommended) or installed directly on Windows.

### 1. Download the server

Download `Asda2-Server-Windows-x86.zip` from [GitHub Releases](https://github.com/wassim-triki/asda2-server-tahadi/releases) and extract it.

Run the following commands from the extracted `Asda2-Server-Windows-x86` directory, which contains `compose.yaml` and `database/`.

### 2. Set up the database

Choose one method.

#### Option A: Docker Compose (recommended)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and start it.
2. Open `compose.yaml` and set `MYSQL_ROOT_PASSWORD` to your own password.
3. Run:

   ```powershell
   docker compose up -d
   ```

This starts MySQL 5.7 at `127.0.0.1:3306`, imports `database/asda2tahadidb.sql` on first initialization, and persists the database in a Docker volume.

#### Option B: Native MySQL 5.7

1. Install **MySQL Server 5.7** from the [MySQL archives](https://downloads.mysql.com/archives/community/) and make sure the MySQL service is running.
2. Open **Command Prompt (`cmd.exe`)** in the extracted server directory and run:

   ```bat
   mysql -u root -p -e "CREATE DATABASE asda2tahadidb"
   mysql --default-character-set=utf8 -u root -p asda2tahadidb < database\asda2tahadidb.sql
   ```

Enter the MySQL root password when prompted. If `mysql` is not recognized, invoke it by its full path (typically `C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe`) without leaving the extracted server directory.

### 3. Configure the server

Open `ReleaseX86\RealmServerConfig.xml` and set the `Pwd=` value in `DBConnectionString` to the MySQL password from step 2. The default host (`127.0.0.1`), port (`3306`), database (`asda2tahadidb`), and user (`root`) match the setup above.

Other settings:

- `Host`: address the server listens on (default `127.0.0.1`).
- `ExternalAddress`: address clients connect to (default `127.0.0.1`).
- `Port`: game server port (default `5000`).
- `RealmName`: server name.

### 4. Start the server

Run `\ReleaseX86.\WCell.RealmServerConsole.exe`

Configure a compatible game client to connect to your server address and port.

## Development

For source builds and local development, see [CONTRIBUTING.md](https://github.com/wassim-triki/asda2-server-tahadi/blob/main/CONTRIBUTING.md).

## Project background

Based on the Tahadi server distribution in [0xFh/Asda2-Project](https://github.com/0xFh/Asda2-Project). This is a community-maintained project, not an official Asda 2 server.
