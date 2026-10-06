# 🐳 DockPHP Cuy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.5-777BB4?logo=php&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-alpine-009639?logo=nginx&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-LTS-003545?logo=mariadb&logoColor=white)
![phpMyAdmin](https://img.shields.io/badge/phpMyAdmin-latest-F89C1D?logo=phpmyadmin&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-informational)

**A lightweight, Docker-powered PHP development environment — XAMPP / Laragon style, without installing anything locally.**

DockPHP Cuy runs a complete PHP stack (Laravel, Symfony, WordPress, or plain PHP) entirely in Docker, with one virtual host per project.

> **No need to install PHP, Nginx, or MariaDB on your machine. Just run Docker and start developing.**

---

## ✨ Features

- 🐘 PHP 8.5 (php-fpm) with a rich set of extensions (see [PHP extensions](#-php-extensions))
- 🌐 Nginx
- 🗄️ MariaDB (LTS)
- 🛠️ phpMyAdmin
- 🚀 Laravel / Symfony / WordPress ready
- 📦 Project files mounted straight from your machine (`./projects` → `/var/www`)
- 🔀 One virtual host per project (`<name>.localhost`)
- 🧱 Configurable CPU / memory limits per service
- ⌨️ `make` wrapper for the common tasks

---

## 🏗️ Services

| Service | Image | Host port | Container |
|---|---|---|---|
| `nginx` | `nginx:alpine` | `${NGINX_PORT}` (default `8000`) | `dockphpcuy-nginx` |
| `php85` | built from [`PHP85/`](PHP85/Dockerfile) | – (internal `9000`) | `dockphpcuy-php85` |
| `mariadb` | `mariadb:lts` | – (internal `3306`) | `dockphpcuy-mariadb-lts` |
| `phpmyadmin` | `phpmyadmin:latest` | `${PHPMYADMIN_PORT}` (default `8080`) | `dockphpcuy-phpmyadmin-latest` |

---

## 📋 Requirements

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose v2
- `make` — optional, only for the command wrapper

```bash
docker --version
docker compose version
```

---

## 🚀 Quick start

```bash
cp .env.example .env     # adjust ports / passwords if you want
make up                  # or: docker compose up -d
```

Then open:

- **Projects** → <http://localhost:8000> (i.e. `http://localhost:${NGINX_PORT}`)
- **phpMyAdmin** → <http://localhost:8080>

> The `php85` image is built from `PHP85/Dockerfile`. The first `make up` builds it
> (use `make rebuild` to force a clean rebuild).

Check everything is healthy:

```bash
make ps
```

---

### Use this as a template

This repo is a starting point — fork or clone it and make it your own:

```bash
git clone git@github.com:fajar7xx/dockphpcuy.git my-stack
cd my-stack
rm -rf .git && git init -b main     # start a fresh history
cp .env.example .env                # set your own ports / passwords
make up
```

Then add your app under `projects/<name>` and open
`http://<name>.localhost:${NGINX_PORT}/` — the quickest way is
`make new name=<name>` (see [projects/README.md](projects/README.md)).

---

## 🔌 Ports

`NGINX_PORT` and `PHPMYADMIN_PORT` in `.env` set the **host** ports. Inside the
containers, Nginx and phpMyAdmin always listen on port `80` — only the host side changes.

| What | URL |
|---|---|
| Nginx (projects) | `http://localhost:${NGINX_PORT}` |
| phpMyAdmin | `http://localhost:${PHPMYADMIN_PORT}` |

If host port `80` is already taken by another service, keep `NGINX_PORT` on a free port
(e.g. `8000`) and access projects as `http://<name>.localhost:8000`.

To drop the port from the URL entirely, you need to own host port `80`:
either stop whatever holds it and set `NGINX_PORT=80`, or add a `*.localhost` reverse-proxy
server block to that other server that forwards to `http://127.0.0.1:${NGINX_PORT}`.

---

## 📁 Project structure

```text
DockPHPCuy/
├── compose.yaml            # the whole stack
├── .env / .env.example     # ports, DB credentials, resource limits
├── Makefile                # `make help` for all commands
│
├── Nginx/
│   └── conf.d/             # one .conf virtual host per project
│
├── PHP85/
│   ├── Dockerfile          # PHP 8.5 image + extensions
│   ├── conf.d/             # php.ini, opcache.ini
│   └── php-fpm.d/          # www.conf (pool config)
│
├── MariaDB/
│   └── data/               # database files (persisted)
│
├── projects/               # your applications  →  /var/www
└── logs/
```

---

## 🧩 Adding a project

1. Put your app in `projects/<name>` (it appears inside the containers as `/var/www/<name>`).
2. Add a virtual host `Nginx/conf.d/<name>.conf` (or let the scaffold do it).
3. Reload Nginx.
4. Open `http://<name>.localhost:${NGINX_PORT}/`.

The quick way — creates the folder, a starter `index.php`, the vhost, and reloads Nginx:

```bash
make new name=myapp
```

Full guide (manual steps, Laravel / WordPress docroots, troubleshooting):
**[projects/README.md](projects/README.md)**.

---

## ⌨️ Common commands

Run `make help` to list everything.

| Command | Description |
|---|---|
| `make up` | Start the stack in the background |
| `make down` | Stop and remove the containers |
| `make restart` | Restart all services |
| `make ps` | Show container status |
| `make logs s=php85` | Follow logs of a service (empty `s` = all) |
| `make bash` | Bash into the PHP container |
| `make sh s=nginx` | Shell into any service |
| `make db` | Open the MariaDB client as root |
| `make exec s=php85 c="php -v"` | Run any command inside a service |
| `make info` | Show PHP version and loaded extensions |
| `make new name=myapp` | Scaffold a new project |
| `make nginx-test` | Validate the Nginx configuration |
| `make nginx-reload` | Reload Nginx after editing a vhost |
| `make build` / `make rebuild` | Build the PHP image (`rebuild` = no cache) |

Prefer raw Docker? Everything maps to `docker compose …`, e.g.:

```bash
docker compose up -d
docker compose exec php85 bash
docker compose logs -f nginx
```

---

## ⚙️ Configuration (`.env`)

```dotenv
MARIADB_ROOT_PASSWORD=...
MARIADB_DATABASE=
MARIADB_USER=...
MARIADB_PASSWORD=...

NGINX_PORT=8000
PHPMYADMIN_PORT=8080

# Resource limits (CPU cores / memory)
NGINX_CPUS=0.25
NGINX_MEMORY=64M
PHP85_CPUS=0.75
PHP85_MEMORY=640M
MARIADB_CPUS=0.75
MARIADB_MEMORY=640M
PHPMYADMIN_CPUS=0.25
PHPMYADMIN_MEMORY=192M
```

The defaults are tuned for a small VPS (**2 vCPU / 2 GB**). On a bigger machine, raise them —
for example `PHP85_MEMORY=2G`, `MARIADB_MEMORY=2G` — then apply with `make up`
(Compose recreates the containers when the limits change).

> **Heads-up:** Docker Compose gives shell environment variables precedence over `.env`.
> If you have, say, `NGINX_PORT` exported in your shell, it wins over `.env`. `unset NGINX_PORT`
> if you want the `.env` value to apply.

---

## 🐘 PHP extensions

**Core (from the base image):**
`ctype, curl, dom, fileinfo, filter, hash, iconv, json, libxml, mbstring, openssl, pcre, PDO, pdo_sqlite, Phar, posix, random, readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, tokenizer, uri, xml, xmlreader, xmlwriter, zlib`

**Installed / PECL:**
`bcmath, exif, gd` (freetype + jpeg + webp)`, igbinary, imagick, intl, mysqli, pcntl, pdo_mysql, pdo_pgsql, redis` (with igbinary serializer)`, soap, sockets, xsl, zip`

**Built-in:** `Zend OPcache`

Need another extension? Edit [`PHP85/Dockerfile`](PHP85/Dockerfile) and run `make rebuild`.

---

## 🌍 Database

- From any container: host `mariadb`, port `3306` (credentials from `.env`).
- `pdo_mysql` and `mysqli` are both available.
- Data is persisted in `./MariaDB/data`.
- GUI: phpMyAdmin at `http://localhost:${PHPMYADMIN_PORT}`, or `make db` for the CLI.

---

## 🔀 Version control (Git)

This repo is meant as a **template / infrastructure** repo: the stack lives here, while
your application code lives in `projects/` and is **not** committed.

Ignored via [`.gitignore`](.gitignore):

| Path | Why |
|---|---|
| `.env` | local secrets / config |
| `MariaDB/data/` | database files (large, machine-specific) |
| `logs/` | runtime logs |
| `projects/*` | your apps — only `projects/README.md` is kept |
| `.commandcode/`, `.rtk/`, `CLAUDE.md` | local tooling |
| `vendor/`, `node_modules/`, `*.log` | dependencies & logs |

### Publish to GitHub

1. Create a **new empty repository** on GitHub — do **not** initialize it with a README,
   `.gitignore`, or license (this repo already ships all of them).
2. Commit and push:

```bash
git add -A
git commit -m "Initial commit: DockPHP Cuy stack"

git remote add origin git@github.com:<you>/dockphpcuy.git
git push -u origin main
```

Or create and push in one step with the GitHub CLI:

```bash
gh repo create dockphpcuy --public --source=. --push
```

> Need to track a specific project after all? Un-ignore it in `.gitignore`
> (e.g. `!projects/myapp/`), but watch out for `vendor/` and `node_modules/`.

---

## 🩺 Troubleshooting

| Symptom | Fix |
|---|---|
| `port is already allocated` / `address already in use` | Change `NGINX_PORT` / `PHPMYADMIN_PORT` in `.env`, then `make up` |
| `502 Bad Gateway` | PHP-FPM is down — check `make ps` and `make logs s=php85` |
| `404 Not Found` on a project | Wrong `root` in the vhost (Laravel/Symfony need `/public`) or the folder is missing |
| Nginx config error | `make nginx-test` to see the reported line |
| Changes to a vhost don't apply | `make nginx-reload` (applies within a moment) |
| Wrong project loads | Check `server_name`, and that only one vhost matches the hostname |

---

## 🤝 Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Notable changes are
tracked in [CHANGELOG.md](CHANGELOG.md), and versions are published as
[GitHub Releases](https://github.com/fajar7xx/dockphpcuy/releases).

---

## 📄 License

Released under the [MIT License](LICENSE).
