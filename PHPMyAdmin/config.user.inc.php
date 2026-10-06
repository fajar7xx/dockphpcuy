<?php

/**
 * phpMyAdmin user configuration.
 *
 * Baked into the image at /etc/phpmyadmin/config.user.inc.php, which is
 * included by /etc/phpmyadmin/config.inc.php.
 *
 * Docs: https://docs.phpmyadmin.net/en/latest/config.html
 */

// Allow switching themes from the UI, and set the default theme.
// The theme is installed into /var/www/html/themes/<name> by PHPMyAdmin/Dockerfile.
$cfg['ThemeManager'] = true;
$cfg['ThemeDefault'] = 'boodark';
