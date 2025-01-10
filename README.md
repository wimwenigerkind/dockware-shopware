# Dockware for Shopware 6

[![MIT licensed](https://img.shields.io/github/license/dockware/dockware.svg?style=flat-square)](https://github.com/dockware/dockware/blob/master/LICENSE)
![Docker Pulls](https://img.shields.io/docker/pulls/dockware/flex)
![Docker Image Size](https://img.shields.io/docker/image-size/dockware/flex)

Welcome to Dockware! For more information, visit [dockware.io](https://dockware.io).

<!-- TOC -->

* [Dockware Dev](#dockware-dev)
    * [What is Dockware Dev?](#what-is-dockware-dev)
    * [When to use this image?](#when-to-use-this-image)
        * [Versioning](#versioning)
        * [Deprecations and Legacy services](#deprecations-and-legacy-services)
    * [Quick Start](#quick-start)
        * [Docker Run](#docker-run)
        * [Docker Compose](#docker-compose)
    * [Documentation and Resources](#documentation-and-resources)
    * [Contribution](#contribution)
    * [Features](#features)
        * [Switch PHP](#switch-php)
        * [Switch Node](#switch-node)
        * [Supervisor](#supervisor)
        * [Conjobs](#conjobs)
        * [Filebeat](#filebeat)
        * [SSH User](#ssh-user)
        * [Tideways](#tideways)
        * [XDebug](#xdebug)
            * [1. Enable/Disable XDebug](#1-enabledisable-xdebug)
            * [2. XDebug Configuration](#2-xdebug-configuration)
        * [Set Custom Timezone](#set-custom-timezone)
        * [Recovery Mode](#recovery-mode)
        * [Set Custom Apache DocRoot](#set-custom-apache-docroot)
        * [Running in CI/CD](#running-in-cicd)
        * [Inject Bootstrap Script](#inject-bootstrap-script)
    * [License](#license)

<!-- TOC -->

## What is Dockware Dev?

Our Dockware images are optimized Docker images for web development in general, but also for Symfony and Shopware projects.

The **dev** image is a ready-to-use image when working with Shopware 6.
It comes with an installed and prepared Shopware 6 instance, so you can immediately start developing.
All required services such as MySQL, but also additional things like AdminerEVO, PimpMyLog, etc. are onboard.
Developers benefit from ready to use features like Xdebug, switching of PHP versions and Node versions and more.

## When to use this image?

This image is a perfect fit for the following use cases.

* Explore any Shopware 6 version
* Develop Shopware 6 plugins, apps, themes
* Use it in pipelines if you need an easy Shopware 6 instance for testing or more

If you develop full Shopware 6 shops, we recommend either using the **essentials** image, or even the **flex** image, if you
know how to use Docker and want to fully rebuild your production environment locally.

### Versioning

While we generally use semantic versioning for other images, this image is a bit different.
We try to use 1 image (name), and therefore we have to use the Docker tag to indicate the Shopware version.

This also gives you the experience, that you can just write any supported Shopware 6 version as tag, without thinking,
and you end up with the correct image and correct Shopware 6 version.

### Deprecations and Legacy services

One thing that is important to us, is that we try to keep the image as slim as possible for developers.
Therefore we only include things like PHP, Node, etc. in versions that are supported by the Shopware version of the image.

## Quick Start

### Docker Run

This is how you launch any Shopware 6 version with Port 80 (HTTP).
Your shop is then available at http://localhost.

You can see when the container is ready by checking the logs with **docker logs**
It usually just needs a few seconds after downloading the image.

```bash 
# launch a Shopware available at http::/localhost
docker run -p 80:80 dockware/dev:6.6.9.0
```

### Docker Compose

This is the same as the docker run command, but as docker-compose.yml file.
In addition, it has **optional environment** variables for PHP and Node versions.

> Please keep in mind, your image will crash if you use PHP or Node versions that do not exist in the image tag version.

```yaml
  shop:
    image: dockware/dev:6.6.9.0
    ports:
      - 80:80
    environment:
      - PHP_VERSION=8.4
      - NODE_VERSION=20
```

## Documentation and Resources

Explore more about Dockware:

- **Website**: [dockware.io](https://dockware.io)
- **Documentation**: Detailed guides and resources are available on the website.
- **Images**: Official image listings and build information can be found at [dockware.io/images](https://dockware.io/images).

## Contribution

Contributions are welcome! Please refer to the `CONTRIBUTING.md` file for guidelines on how to contribute effectively.

## Features

### Switch PHP

```bash 
cd /var/www
make switch-php version=8.2
```

### Switch Node

```bash
cd /var/www
make switch-node version=20
```

### Supervisor

```bash
ENV SUPERVISOR_ENABLED=1

volume: /etc/supervisor/supervisord.conf

[program:my-worker-process]
process_name=%(program_name)s_%(process_num)02d
command=php bin/console xyz
directory=/var/www/html
user=www-data
group=www-data
numprocs=2
autostart=true
autorestart=true
stdout_logfile=/var/log/worker.out.log
stderr_logfile=/var/log/worker.err.log
```

### Conjobs

```bash  
docker cp ./dev/config/shop/crontab.txt container:/var/www/crontab.txt
docker exec -it container bash -c 'crontab /var/www/crontab.txt && sudo service cron restart'
```

### Filebeat

```bash  
/etc/filebeat/filebeat.yml

name: "shop"

filebeat.inputs:

- type: log
  enabled: true
  paths:
    - /var/www/html/var/log/*.log
      tags: ["shop"]

output.logstash:
hosts: ["logstash:5044"]
```

### SSH User

The image has a built-in SFTP services.
You can create a custom user for SFTP/SSH access by setting the following ENV variables:

```bash
ENV SSH_USER=shopware
ENV SSH_PWD=shopware
```

### Tideways

You can enable Tideways by setting the following ENV variable:

```bash
TIDEWAYS_KEY=abc
```

### XDebug

#### 1. Enable/Disable XDebug

You can either enable Xdebug initially by setting the ENV variable `XDEBUG_ENABLED` to 1 (ON) or 0 (OFF) or by executing the following
command in an existing container:

```bash 
cd /var/www
make xdebug-on
make xdebug-off
```

#### 2. XDebug Configuration

Xdebug should already work out of the box in most cases.
If not, you can adjust the following ENV variables.

```bash
# Use default value for MAC + Windows, and 172.17.0.1 for Linux
# Default value: host.docker.internal
XDEBUG_REMOTE_HOST 

# IDE Key identifier for XDebug
# Default value: idekey=PHPSTORM
XDEBUG_CONFIG

# Used for the serverName export for XDebug usage on CLI
# Default value: serverName=localhost
PHP_IDE_CONFIG 
```

### Set Custom Timezone

You can adjust custom timezones for both the operating system as well as PHP by setting the following ENV variables.
Dockware will automatically adjust settings and PHP configurations accordingly when you boot the image, or when you switch PHP versions.

```bash
ENV TZ=Europe/Berlin
```

### Recovery Mode

Values: 1|0
if enabled, nothing will be done in the entrypoint when booting dockware. This allows you to access the container on problems

```bash 
RECOVERY_MODE 
```

### Set Custom Apache DocRoot

```bash
# Default value: /var/www/html/public
APACHE_DOCROOT=/var/www/vhosts/xyz/html
```

### Running in CI/CD

If you run containers with DOCKWARE_CI=1 the containers will automatically quit after running your command.
Use this if you use dockware as command runner in your CI/CD system.
Please note, your containers should automatically exit once a custom command is provided.
This is just fa fallback if they do not exit as expected.

```bash
DOCKWARE_CI=1
```

### Inject Bootstrap Script

You can inject a custom script that will be executed on container boot.
This can either be at the start or the end of the boot process.

Mount any Shell script to the following paths:

* `/var/www/boot_start.sh`
* `/var/www/boot_end.sh`

If dockware detects a script at these paths, it will execute them accordingly.

## License

Dockware Dev is provided under the MIT license. As with all Docker images, this project may include software under other licenses. Users are responsible for ensuring compliance with all relevant licenses for software contained within the image.