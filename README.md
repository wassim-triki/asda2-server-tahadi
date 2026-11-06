# Asda 2 Tahadi Server

A WCell-based private server for **Asda 2 (Tahadi)**, maintained as part of the Asda 2 Local project.

## Current Status

The server is experimental but playable. Login, characters, movement, combat, loot, inventory, persistence, and multiplayer have been tested.

Some systems, notably quests, remain incomplete.

## Getting Started

**Requirements:** Windows, .NET Framework 4.0 runtime, MySQL 5.7, and a compatible game client (separate).

### 1. Set Up the Database

Choose one of the following options. Database setup files are available in the repository.

**Option 1: Docker Compose (recommended)**
Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and run from the repository root:

```bash
docker compose up -d
```

This starts MySQL 5.7, imports `database/asda2tahadidb.sql` on first initialization, and stores the database in a persistent volume.

Default connection: `127.0.0.1:3306`, database `asda2tahadidb`, user `root`, password `asda2_dev_root` (unless overridden).

**Option 2: Native MySQL 5.7**

Install MySQL 5.7 and import the database from the repository root:

```bat
mysql -u root -p -e "CREATE DATABASE asda2tahadidb"
mysql --default-character-set=utf8 -u root -p asda2tahadidb < database\asda2tahadidb.sql
```

### 2. Get the Server

**Option 1: Prebuilt Release**

1. Download `Asda2-Server-Windows-x86.zip` from [GitHub Releases](https://github.com/wassim-triki/asda2-server-tahadi/releases).
2. Extract it anywhere on Windows.
3. Continue to configuration below.

**Option 2: Build from Source**

Install [Visual Studio 2019 Build Tools](https://aka.ms/vs/16/release/vs_buildtools.exe), including MSBuild and the **.NET Framework 4 targeting pack**.

From PowerShell at the repository root:

```powershell
.\scripts\package.ps1
```

This builds `Release|x86` and generates:

```text
dist/
├── Asda2-Server-Windows-x86/
└── Asda2-Server-Windows-x86.zip
```

To package an existing Release build:

```powershell
.\scripts\package.ps1 -skipBuild
```

For a manual Debug build without packaging:

```bat
MSBuild Asda2_Server.sln /p:Configuration=Debug /p:Platform=x86
```

### 3. Configure and Run

**Prebuilt or packaged server:** Edit `RealmServerConfig.xml` if needed, then launch `ReleaseX86\WCell.RealmServerConsole.exe`.

**Manual Debug build:** Copy `assets\RealmServerConfig.xml` to `Run\DebugX86\` and edit it.

In `RealmServerConfig.xml`, configure:

- `DBConnectionString`: MySQL host, port, database, and credentials.
- `Host` and `ExternalAddress`: Server listening and client connection addresses.
- `Port`: Game server port.
- `RealmName`: Server name.

Make sure MySQL is running, then launch `WCell.RealmServerConsole.exe` from its runtime directory. Configure your compatible client to connect to the server's address and port.

## Source

Based on the Tahadi server distribution available in [0xFh/Asda2-Project](https://github.com/0xFh/Asda2-Project).
