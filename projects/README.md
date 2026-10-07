# Projects

Your PHP application code lives here. This directory is bind-mounted into the containers:

```text
host:      ./projects/<name>
container: /var/www/<name>
```

So `projects/myapp` is available inside the PHP containers as `/var/www/myapp`.

> Do not put Docker / infrastructure configuration here — application source only.

---

## Adding a new project (step by step)

> **Quick way:** `make new name=myapp` does steps 1-3 for you (creates the folder,
> a starter `index.php`, the vhost, and reloads nginx). The manual steps below are
> for when you want to do it yourself.

### 1. Create the project folder

```bash
mkdir -p projects/myapp
# then copy or create your application files inside it
```

### 2. Add an Nginx virtual host

Create a new file `Nginx/conf.d/myapp.conf`:

```nginx
server {
    listen 80;
    server_name myapp.localhost;

    root /var/www/myapp;               # Laravel/Symfony: /var/www/myapp/public
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass php85:9000;       # `php85` = the Docker Compose service name
    }
}
```

Notes:
- `fastcgi_pass php85:9000;` — `php85` is the Compose service name, resolved on the internal network.
- One file per project; the filename is free (it does not have to match anything).
- The container **always listens on port 80**; the host port is set by `NGINX_PORT` in `.env`.

### 3. Reload Nginx

Adding/editing a vhost only needs a reload (no container restart):

```bash
docker compose exec nginx nginx -s reload
```

> The reload applies within a moment. If you still get the old site, just run the
> reload once more (or check `docker compose exec nginx nginx -t`).

### 4. Open the project

Use the host port from `.env` (`NGINX_PORT`, currently `8000`):

```text
http://myapp.localhost:8000/
```

If the stack is published on host port **80**, the port can be omitted:

```text
http://myapp.localhost/
```

> `*.localhost` resolves to `127.0.0.1` automatically on most systems (RFC 6761).
> When accessing from another machine, add a hosts entry on **that** machine, e.g.
> `192.168.1.10  myapp.localhost`.

---

## Framework notes

### Laravel / Symfony

```nginx
root /var/www/myapp/public;
location / { try_files $uri $uri/ /index.php?$query_string; }
```

### WordPress

```nginx
root /var/www/myapp;
index index.php;
location / { try_files $uri $uri/ /index.php?$is_args$args; }
```

#### Updating WordPress from the dashboard

WordPress asks for FTP credentials when PHP-FPM cannot safely write to the site files.
This stack runs PHP-FPM as `www-data` and mounts `projects/` into the container, so
WordPress needs write access to the site root and the plugin and theme directories.

1. In `projects/myapp/wp-config.php`, add this before the “That’s all, stop editing!”
   line:

   ```php
   define('FS_METHOD', 'direct');
   ```

   This tells WordPress to use direct filesystem access; it does not grant file permissions.
2. Choose one of these permission approaches. Run commands from the repository root and
   replace `myapp` with the project directory.

**Option A — keep the host owner (recommended).** Grant write access to PHP-FPM without
changing the owner. On Linux, install `acl` if `setfacl` is unavailable, then run:

```bash
www_data_uid=$(docker compose exec -T php85 id -u www-data | tr -d '\r')
setfacl -R -m "u:${www_data_uid}:rwX" projects/myapp
find projects/myapp -type d -exec setfacl -m "d:u:${www_data_uid}:rwx" {} +
```

The default ACL lets WordPress create files and directories during later updates. On macOS
with Docker Desktop, add an ACL for your host user while preserving file ownership:

```bash
chmod -R +a "user:$(id -un) allow read,write,execute,delete,add_file,add_subdirectory,file_inherit,directory_inherit" projects/myapp
```

**Option B — make `www-data` the owner.** Simple and works on Linux and macOS:

```bash
docker compose exec -u root php85 chown -R www-data:www-data /var/www/myapp
```

This changes ownership of the bind-mounted files. The host user may no longer be able to
edit them without changing permissions or ownership again.

Docker Desktop's file sharing can affect how these permissions appear inside the container.
Check that PHP-FPM can write before relying on dashboard updates:

```bash
docker compose exec -u www-data php85 sh -c \
  'test -w /var/www/myapp && test -w /var/www/myapp/wp-content/plugins && test -w /var/www/myapp/wp-content/themes'
```

If the check fails, do not use `chmod -R 777`; review the host ACL or use Option A.
Back up the site before updating WordPress, plugins, or themes.

For WordPress filesystem behavior, see the
[WordPress Filesystem API documentation](https://developer.wordpress.org/apis/filesystem/).

---

### Plain PHP

```nginx
root /var/www/myapp;
index index.php index.html;
```

---

## Connecting to the database

- From inside the PHP containers: host `mariadb`, port `3306`, credentials from `.env`.
- PHP extensions `pdo_mysql` and `mysqli` are both available.

---

## Useful commands

```bash
docker compose ps                      # container status
docker compose exec nginx nginx -t     # validate nginx config
docker compose exec nginx nginx -s reload
docker compose logs -f nginx           # follow nginx logs
docker compose exec php85 php -v       # PHP version
```

---

## Troubleshooting

- **404** — check the `root` path (Laravel/Symfony usually need `/public`) and that the folder exists under `projects/`.
- **502 Bad Gateway** — PHP-FPM not reachable. Make sure `fastcgi_pass php85:9000;` matches a running service and `docker compose ps` shows `php85` healthy.
- **Config error** — run `docker compose exec nginx nginx -t` and read the reported line.
- **Wrong site loads** — check `server_name`, and remember to reload nginx after adding a vhost.
