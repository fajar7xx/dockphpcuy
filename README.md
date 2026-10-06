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
- 🛠️ phpMyAdmin (with the BooDark theme)
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
| `phpmyadmin` | built from [`PHPMyAdmin/`](PHPMyAdmin/Dockerfile) | `${PHPMYADMIN_PORT}` (default `8080`) | `dockphpcuy-phpmyadmin` |

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

- **Projects root** → <http://localhost:8000> (i.e. `http://localhost:${NGINX_PORT}`)
- **A project** → `http://<name>.localhost:${NGINX_PORT}` (e.g. <http://myapp.localhost:8000>)
- **phpMyAdmin** → <http://localhost:8080> (login details in [Database](#-database))

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
├── PHPMyAdmin/
│   ├── Dockerfile          # phpMyAdmin image + BooDark theme
│   └── config.user.inc.php # phpMyAdmin user config (default theme)
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

## 📚 Framework tutorials

All commands run **inside the `php85` container** (it ships Composer, Git, cURL and PHP).
From the repo root use `docker compose exec php85 sh -c '…'`, or open a shell with `make bash`.

Every framework follows the same flow: create the project under `/var/www` (= `./projects/`),
add a vhost, reload Nginx, open `http://<name>.localhost:${NGINX_PORT}/`.

The vhost is identical for all frameworks except `root` — save it as `Nginx/conf.d/myapp.conf`:

```nginx
server {
    listen 80;
    server_name myapp.localhost;
    root /var/www/myapp/public;          # Laravel / Symfony / CodeIgniter use /public
    index index.php index.html;          # WordPress / plain PHP use /var/www/myapp
    location / { try_files $uri $uri/ /index.php?$query_string; }
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass php85:9000;
    }
}
```

```bash
make nginx-reload
```

### Plain PHP

```bash
make new name=myapp        # creates the folder, a starter index.php, the vhost, reloads nginx
```

### Laravel

```bash
docker compose exec php85 sh -c 'cd /var/www && composer create-project laravel/laravel myapp'
```

Set `root /var/www/myapp/public;` in the vhost. In `projects/myapp/.env`:

```dotenv
DB_CONNECTION=mysql
DB_HOST=mariadb
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=<MARIADB_ROOT_PASSWORD>
```

Create the `laravel` database (phpMyAdmin or `make db`), then migrate:

```bash
docker compose exec php85 sh -c 'cd /var/www/myapp && php artisan migrate'
```

### Symfony

```bash
docker compose exec php85 sh -c 'cd /var/www && composer create-project symfony/skeleton:"^7" myapp'
# full-stack: docker compose exec php85 sh -c 'cd /var/www/myapp && composer require webapp'
```

Set `root /var/www/myapp/public;`. In `projects/myapp/.env`:

```dotenv
DATABASE_URL="mysql://root:<MARIADB_ROOT_PASSWORD>@mariadb:3306/myapp?serverVersion=mariadb-11.4.0&charset=utf8mb4"
```

> `serverVersion` should match your MariaDB — run `SELECT VERSION();` in phpMyAdmin.
> Create the `myapp` database first.

### CodeIgniter 4

```bash
docker compose exec php85 sh -c 'cd /var/www && composer create-project codeigniter4/appstarter myapp'
```

Set `root /var/www/myapp/public;`. In `projects/myapp/.env` (a copy of the shipped `env`):

```dotenv
database.default.hostname = mariadb
database.default.database = myapp
database.default.username = root
database.default.password = <MARIADB_ROOT_PASSWORD>
database.default.DBDriver = MySQLi
```

### WordPress

```bash
# 1. download WordPress into projects/myapp
docker compose exec php85 sh -c 'cd /var/www && curl -sL https://wordpress.org/latest.tar.gz | tar xz && mv wordpress myapp'

# 2. create the config file
docker compose exec php85 sh -c 'cd /var/www/myapp && cp wp-config-sample.php wp-config.php'
```

Set `root /var/www/myapp;` in the vhost. Edit `projects/myapp/wp-config.php`:

```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');            // or MARIADB_USER from .env
define('DB_PASSWORD', '<MARIADB_ROOT_PASSWORD>');
define('DB_HOST', 'mariadb');         // the Docker service name
```

Create the `wordpress` database, reload Nginx, then open
`http://myapp.localhost:${NGINX_PORT}/` and run the installer.

> WordPress needs `mysqli` (installed) and a writable `wp-content/`. If uploads fail, check
> ownership under `projects/myapp/wp-content`.

> **File ownership:** files created inside the container are owned by `root`. To create them
> owned by your host user instead, run as yourself:
> `docker compose exec -u "$(id -u):$(id -g)" -e COMPOSER_HOME=/tmp/composer php85 sh -c '…'`.

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
| `make pma-setup` | Enable phpMyAdmin's configuration storage (pmadb) |
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
- phpMyAdmin uses the **BooDark** theme. To switch themes, set `PMA_THEME` /
  `PMA_THEME_VERSION` in [`PHPMyAdmin/Dockerfile`](PHPMyAdmin/Dockerfile) and update
  `$cfg['ThemeDefault']` in [`PHPMyAdmin/config.user.inc.php`](PHPMyAdmin/config.user.inc.php),
  then run `make build`.

### Connect with phpMyAdmin

Open `http://localhost:${PHPMYADMIN_PORT}` (default <http://localhost:8080>) and log in with:

| Field | Value |
|---|---|
| **Server** | `mariadb` |
| **Username** | `root`, or `MARIADB_USER` from `.env` |
| **Password** | `MARIADB_ROOT_PASSWORD`, or `MARIADB_PASSWORD` from `.env` |

Use `mariadb` as the server host — phpMyAdmin talks to MariaDB over the internal Docker
network, **not** `localhost`. The database is **not** published to your host by default, so
from your machine use phpMyAdmin in the browser or `make db` for a CLI client; if you want a
desktop client (TablePlus, DBeaver…), add a `ports:` mapping to the `mariadb` service.

> Need a database before installing an app? Create it from phpMyAdmin (or `make db` →
> `CREATE DATABASE myapp;`). Dumping/importing works from phpMyAdmin's **Import**/**Export** tabs.

#### Configuration storage (pmadb)

phpMyAdmin's extended features (relations, bookmarks, SQL history, designer, …) need the
`phpmyadmin` database with its `pma__*` tables. Create them once (idempotent):

```bash
make pma-setup
```

Without this, phpMyAdmin shows *"The phpMyAdmin configuration storage is not completely
configured"* and disables those features.

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
