# Asda 2 Tahadi Server

A WCell-based private server for **Asda 2 (Tahadi)**, maintained as part of the Asda 2 Local project.

## Current Status

The server is experimental but playable. Login, character management, movement, combat, loot, inventory, persistence, and multiplayer have been tested successfully.

Some systems remain incomplete, notably quests.

## Getting Started

WCell runs on **Windows**, with **MySQL 5.7** provided through Docker Compose. A compatible game client is required separately.

### Prerequisites

- Windows with MSBuild (tested with Visual Studio 2022 Build Tools).
- .NET Framework 4.0 reference assemblies.
- Docker Desktop with Compose, or a native MySQL 5.7 installation.

### Database

From the repository directory:

```sh
docker compose up -d
```

On first startup, MySQL imports `database/asda2tahadidb.sql`. Data is preserved in a Docker volume.

The database is available at `127.0.0.1:3307`; development credentials are defined in `compose.yaml`.

### Build and run

Open a **Visual Studio Developer Command Prompt** (or a terminal with MSBuild configured).

If you don't have the .NET Framework 4.0 reference assemblies, download [Microsoft.NETFramework.ReferenceAssemblies.net40](https://www.nuget.org/packages/Microsoft.NETFramework.ReferenceAssemblies.net40/) from NuGet and extract the package. You can point MSBuild to its `build` directory using `TargetFrameworkRootPath`.

From the folder containing `Asda2_Server.sln`, build with:

```bat
MSBuild Asda2_Server.sln /p:Configuration=Debug /p:Platform=x86
```

If MSBuild cannot find the reference assemblies, use:

```bat
MSBuild Asda2_Server.sln /p:Configuration=Debug /p:Platform=x86 /p:TargetFrameworkRootPath="C:\path\to\package\build\"
```

Copy `assets\RealmServerConfig.xml` to `Run\DebugX86\RealmServerConfig.xml` (or update the runtime file if it already exists), then launch:

```bat
cd Run\DebugX86
WCell.RealmServerConsole.exe
```

Configure your game client to connect to the address and port in the runtime XML.

### Database management

```sh
docker compose down       # Stop and remove containers; keep database data
docker compose up -d      # Start again with existing data
docker compose down -v    # Reset: delete the database volume and all its data
```

### Without Docker

Alternatively, you can install **MySQL 5.7** directly on Windows.

```bat
mysql -u root -p -e "CREATE DATABASE asda2tahadidb"
mysql --default-character-set=utf8 -u root -p asda2tahadidb < database\asda2tahadidb.sql
```

Don't forget to update the runtime XML connection string to match your MySQL instance.

**Note:** The supplied development credentials and `SslMode=None` are intended for local use only.

## Source

Based on the Tahadi server distribution also available in [0xFh/Asda2-Project](https://github.com/0xFh/Asda2-Project).
