# How to Contribute?

<!-- TOC -->

* [How to Contribute?](#how-to-contribute)
    * [Add a new Shopware version](#add-a-new-shopware-version)
    * [Modify the Image](#modify-the-image)
        * [Modifying PHP](#modifying-php)
        * [Modifying Node](#modifying-node)
        * [Other Changes](#other-changes)
    * [Testing](#testing)

<!-- TOC -->

## Add a new Shopware version

If you want to add a new Shopware version, you first need to add the configuration for this version.
What PHP versions are supported? What Node version?

Open the file **./scripts/shopware-overview.json** and add your data.

Now copy the latest **SVRUNIT XML Configuration** for the new Shopware version.
Please double-check the tests and adjust if needed.

> Pro Tip: stick to the {{tag}} tags to avoid (future) copy/paste errors of Shopware versions.

And that's it.
Please test it locally by running this simple makefile command

```bash
make all shopware=x.x.x.x
```

## Modify the Image

### Modifying PHP

All PHP installation scripts and configurations are located in **`./src/scripts/install_php.sh`** and the **`php`** directory.

To install a specific PHP version:

1. Create a separate script in **`./src/scripts/php/install_phpX.Y.sh`**, where `X.Y` is the PHP version.
2. Modify the **`./src/scripts/install_php.sh`** file to reference your new script.

When building the image, your PHP modifications will be automatically applied.

If you need to make changes that affect all PHP versions:

- Add the changes directly to **`install_php.sh`**.

For PHP-related changes that are not tied to the PHP installation itself, include them in the PHP **run layer** within the **Dockerfile**.

### Modifying Node

All Node.js installation scripts and configurations are located in **`./src/scripts/install_node.sh`**.

To install a specific Node.js version:

- Add the version details to **`./src/scripts/install_node.sh`**.

When building the image, your Node.js modifications will be automatically applied.

Adding additional NPM packages should also take place in the **`install_node.sh`** script.

### Other Changes

For any other modifications or additions:

- Aim to keep the **Dockerfile** as clean and organized as possible.
- Install additional tools or dependencies in the run layer using **`apt-get install`** commands.

## Testing

When adding new features or modifying existing ones:

1. Write corresponding **SVRUnit** tests to validate your changes.
2. Execute the tests using the appropriate command in the **makefile**.

**SVRUnit** tests are categorized into sections such as **core**, **features**, **php**, and **node**. This structure ensures the tests are organized and easy to maintain.