# Contributing to DockPHP Cuy

Thanks for wanting to help! DockPHP Cuy is a Docker-based PHP development
environment meant to be **shared and reused** — contributions that make it easier
for others to run their PHP projects are very welcome.

## Ways to contribute

- 🐛 Report bugs or suggest features via [Issues](../../issues/new/choose)
- 📖 Improve the docs (`README.md`, `projects/README.md`)
- 🐘 Add or adjust PHP extensions in `PHP85/Dockerfile`
- ⚙️ Improve the `Makefile`, compose file, or Nginx defaults
- 🔀 Add support for more frameworks or PHP versions

## Development setup

```bash
git clone git@github.com:fajar7xx/dockphpcuy.git
cd dockphpcuy
cp .env.example .env
make up            # or: docker compose up -d
make ps
```

Handy during development:

```bash
make logs s=php85      # follow logs
make bash              # shell into the PHP container
make nginx-test        # validate nginx config
make rebuild           # rebuild the PHP image without cache
```

## Project conventions

- **Application code is not committed.** Everything under `projects/*` is ignored
  (only `projects/README.md` is kept). Keep infrastructure changes in this repo,
  app code in your own.
- **One vhost per project**: `Nginx/conf.d/<name>.conf` with `server_name <name>.localhost`.
- The **container always listens on port `80`**; only the host port (`NGINX_PORT`) varies.
- Add PHP extensions in `PHP85/Dockerfile` and rebuild — keep the image reproducible.
- Keep resource limits configurable through `.env` (`*_CPUS`, `*_MEMORY`).

## Before opening a PR

1. `docker compose config -q` is valid.
2. `make nginx-test` passes.
3. `cp .env.example .env && make up` starts the stack healthy (`make ps`).
4. If the image changed, `make rebuild` succeeds.
5. Update `README.md` and `CHANGELOG.md` when relevant.

CI runs these checks automatically — see [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Commit messages

Short, descriptive, imperative mood:

```
Add xsl, imagick and igbinary extensions
Fix php-fpm pool path in the compose mount
```

## Releasing

Releases are driven by Git tags and `CHANGELOG.md`:

1. Move the `[Unreleased]` entries in `CHANGELOG.md` into a new versioned section
   (e.g. `## [0.2.0] - YYYY-MM-DD`) and update the link at the bottom.
2. Commit it (`Release v0.2.0`).
3. Tag and push:

```bash
git tag -a v0.2.0 -m "v0.2.0"
git push origin main --follow-tags
```

Pushing a `v*.*.*` tag triggers [`.github/workflows/release.yml`](.github/workflows/release.yml),
which publishes a GitHub Release with auto-generated notes.

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
