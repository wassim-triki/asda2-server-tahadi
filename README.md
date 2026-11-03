# Asda 2 Tahadi Server

A WCell-based private server for **Asda 2 (Tahadi)**, maintained as part of the Asda 2 Local project.

## Current Status

The server is experimental but playable. Login, character management, movement, combat, loot, inventory, persistence, and multiplayer have been tested successfully.

Some systems remain incomplete, notably quests.

## Getting Started

The server runs on **Windows**, targets **.NET Framework 4.0**, and requires **MySQL 5.7**. A compatible game client is required separately.

### 1. Build from Source

We use **MSBuild from Visual Studio 2019** to compile the server. The full Visual Studio IDE is not required.

1. Download [Visual Studio 2019 Build Tools](https://aka.ms/vs/16/release/vs_buildtools.exe) from Microsoft.
2. Select the **.NET desktop build tools** workload and ensure **.NET Framework 4 targeting pack** is selected under Individual components.
3. Open **Developer Command Prompt for VS 2019** and verify the installation with `msbuild -version`.

From the repository root, build the solution:

```bat
MSBuild Asda2_Server.sln /p:Configuration=Debug /p:Platform=x86
```

The compiled executable is generated at `Run\DebugX86\WCell.RealmServerConsole.exe`.

### 2. Database

Choose one of the following MySQL 5.7 setups.

**Option A: Docker Compose (recommended)**

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and run from the repository root:

```bat
docker compose up -d
```

MySQL automatically imports `database/asda2tahadidb.sql` on first startup and persists data in a Docker volume. It is available at `127.0.0.1:3306`, using the credentials in `compose.yaml`.

To manage the database:

```bat
docker compose down       # Stop, preserve data
docker compose up -d      # Start
docker compose down -v    # Reset, delete all database data
```

**Option B: Native MySQL 5.7**

Install [MySQL Server 5.7](https://dev.mysql.com/downloads/installer/5.7.html) using its default settings.

From the repository root, using the MySQL command-line client:

```bat
mysql -u root -p -e "CREATE DATABASE asda2tahadidb"
mysql --default-character-set=utf8 -u root -p asda2tahadidb < database\asda2tahadidb.sql
```

### 3. Configure and Run

Copy the supplied configuration template into the runtime directory:

```bat
copy assets\RealmServerConfig.xml Run\DebugX86\RealmServerConfig.xml
```

Edit `Run\DebugX86\RealmServerConfig.xml` and verify that `DBConnectionString` matches your MySQL port and credentials.

Launch the server:

```bat
cd Run\DebugX86
WCell.RealmServerConsole.exe
```

Configure your compatible game client to connect to the server's configured address and port.

## Source

Based on the Tahadi server distribution available in [0xFh/Asda2-Project](https://github.com/0xFh/Asda2-Project).
