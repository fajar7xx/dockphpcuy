# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-06

### Added

- Docker stack: PHP 8.5 (FPM), Nginx, MariaDB (LTS) and phpMyAdmin
- PHP extensions: `bcmath`, `exif`, `gd` (freetype/jpeg/webp), `intl`, `mysqli`,
  `pcntl`, `pdo_mysql`, `pdo_pgsql`, `soap`, `sockets`, `xsl`, `zip`, plus PECL
  `redis` (with igbinary), `igbinary` and `imagick`
- Per-project virtual hosts (`<name>.localhost`) under `Nginx/conf.d/`
- `make` wrapper for common tasks (`up`, `down`, `bash`, `logs`, `db`, `new`, …)
- `make new name=…` scaffolder for new projects
- Configurable CPU / memory limits per service via `.env`
- Documentation: `README.md`, `projects/README.md`, `CONTRIBUTING.md`
- MIT license

[Unreleased]: https://github.com/fajar7xx/dockphpcuy/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fajar7xx/dockphpcuy/releases/tag/v0.1.0
