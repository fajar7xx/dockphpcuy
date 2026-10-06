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
