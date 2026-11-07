# Development setup

This guide covers building and running the Asda 2 Tahadi server from source. To host a prebuilt server, see [README.md](README.md).

## Requirements

- Windows.
- [Visual Studio 2019 Build Tools](https://aka.ms/vs/16/release/vs_buildtools.exe) with MSBuild and the .NET Framework 4 targeting pack.
- MySQL 5.7, via Docker Compose or a native installation (see [database setup](README.md#2-set-up-the-database)).
- A compatible game client for in-game testing.

## Clone and build

```powershell
git clone https://github.com/wassim-triki/asda2-server-tahadi.git
cd asda2-server-tahadi
.\scripts\build.ps1
```

This builds **Debug x86**. To rebuild **Release x86** instead:

```powershell
.\scripts\build.ps1 -Release
```

The build script finds MSBuild through `PATH` or Visual Studio's `vswhere` utility.

## Set up the database

Use either database method in the [README](README.md#2-set-up-the-database).

For Docker development, leave the tracked `compose.yaml` unchanged. Create an ignored `compose.override.yaml` in the repository root with your password:

```yaml
services:
  db:
    environment:
      MYSQL_ROOT_PASSWORD: "your-password"
```

Then start the database:

```powershell
docker compose up -d
```

## Run the development server

After building, copy `assets\RealmServerConfig.xml` to `Run\DebugX86\RealmServerConfig.xml` if the file is missing. Set `Pwd=` in `DBConnectionString` to your database password and adjust the server addresses if needed.

Run from the output directory:

```powershell
cd .\Run\DebugX86
.\WCell.RealmServerConsole.exe
```
