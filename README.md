# Snipe-it Docker Compose

# Steps to run

## Generate `.env` in the project root

`.env` file example
```
VOLUME_ROOT=./volumes
DOMAIN_NAME=<<YOUR_DOMAIN_NAME>>

# Mysql Parameters
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=YOUR_SUPER_SECRET_PASSWORD
MYSQL_DATABASE=snipeit
MYSQL_USER=snipeit
MYSQL_PASSWORD=YOUR_snipeit_USER_PASSWORD

# Email Parameters
MAIL_PORT_587_TCP_ADDR=smtp.whatever.com
MAIL_PORT_587_TCP_PORT=587
MAIL_ENV_FROM_ADDR=youremail@yourdomain.com
MAIL_ENV_FROM_NAME=Your Full Email Name
MAIL_ENV_ENCRYPTION=tcp # pick 'tls' for SMTP-over-SSL, 'tcp' for unencrypted
MAIL_ENV_USERNAME=your_email_username
MAIL_ENV_PASSWORD=your_email_password

# Snipe-IT Settings
APP_ENV=production
APP_DEBUG=false
APP_KEY=<<YOUR_API_KEY>> # Check the `README.md` to know how to obtain it
APP_TIMEZONE=Europe/Madrid
APP_LOCALE=en
```

## Get the APP_KEY

To get the application key needed run:

``` sh
docker run --rm snipe/snipe-it
```

Paste the key into the APP_KEY in `.env` file
