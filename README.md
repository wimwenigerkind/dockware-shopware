# Dockware for Shopware

[![MIT licensed](https://img.shields.io/github/license/dockware/dockware.svg?style=flat-square)](https://github.com/dockware/dockware/blob/master/LICENSE)
![Docker Pulls](https://img.shields.io/docker/pulls/dockware/flex)
![Docker Image Size](https://img.shields.io/docker/image-size/dockware/flex)

Welcome to Dockware! For more information, visit [dockware.io](https://dockware.io).

## What is Dockware for Shopware?

Our Dockware images are optimized Docker images for web development in general, but also for Symfony and Shopware projects.

This repository contains the source code for 2 images **dockware/shopware** and **dockware/shopware-essentials**.
It's a perfect match if you work with Shopware 6.

While the **shopware-essentials** image comes with everything you need to run your own Shopware version inside a single container,
the pure **shopware** image comes with an installed and prepared Shopware 6 instance, so you can immediately start developing.

All required services such as MySQL, but also additional things like AdminerEVO, PimpMyLog, etc. are included in both images.
Developers benefit from ready to use features like Xdebug, switching of PHP versions, Node versions and more.

## When to use this image?

These images are a perfect fit for the following use cases.

* Explore any Shopware 6 version
* Develop Shopware 6 plugins, apps, themes
* Use it in pipelines if you need an easy Shopware 6 instance for testing or more

If you develop full Shopware 6 shops, we recommend either using the **shopware-essentials** image, or even the **dockware/web** image, if you
know how to use Docker and want to fully rebuild your production environment locally.

## Versioning

While we generally use semantic versioning for other images, the **dockware/shopware** is a bit different.
We try to use 1 image (name), and therefore we have to use the Docker tag to indicate the **Shopware version**.

This also gives you the experience, that you can just write any supported Shopware 6 version as tag, without thinking,
and you end up with the correct image and correct Shopware 6 version.

The **dockware/shopware-essentials** image is versioned with semantic versioning.

The source code in this repository is always the **latest Shopware version**.
We use Git Tags to indicate releases (release-6.6.9.0).
If an older Shopware version needs a fix, we will create a separate branch for this where we fix the issue and create a second tag (release-6.6.9.0-v2).

## Deprecations and Legacy services

One thing that is important to us, is that we try to keep the image as slim as possible for developers.
Therefore we only include packages like PHP, Node, etc. in versions, that are supported by the Shopware version of the image.

Please keep in mind, that this is the **next generation** of our dockware images.
You may find older Shopware versions in the images **dockware/dev** or **dockware/play**.

## Quick Start

### Docker Run

This is how you launch a Shopware 6 version with Port 80 (HTTP).
Your shop is then available at http://localhost.

You can see when the container is ready by checking the logs with **docker logs**
It usually just needs a few seconds after downloading the image.

```bash 
# launch a Shopware available at http::/localhost
docker run -p 80:80 dockware/shopware:6.7.2.0
```

### Docker Compose

This is the same as the docker run command, but as docker-compose.yml file.
In addition, it has **optional environment** variables for PHP and Node versions.

> Please keep in mind, your image will crash if you use PHP or Node versions that do not exist in the image tag version.

```yaml
  shop:
    image: dockware/shopware:6.7.2.0
    ports:
      - 80:80
    environment:
      - PHP_VERSION=8.4
      - NODE_VERSION=20
```

## Documentation

For all these cool features like Xdebug, Filebeat, PHP Switching, Supervisor and more,
please check out the Docs at [https://dockware.io](https://dockware.io).

## Contribution

Contributions are welcome! Please refer to the `CONTRIBUTING.md` file for guidelines on how to contribute effectively.

## License

Dockware for Shopware is provided under the MIT license. As with all Docker images, this project may include software under other licenses.
Users are responsible for ensuring compliance with all relevant licenses for software contained within the image.