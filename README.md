<h1 align="center">
PHP SPX Installer
    <br>
</h1>

* An installer for [PHP SPX](https://github.com/NoiseByNorthwest/php-spx) profiler, that solves [hopefully] most of the encountered issues and works for all supported versions including cli and fpm</h3>
* It also supports multiple PHP versions on the same machine

[![Author](https://img.shields.io/badge/author-@medunes-blue.svg?style=flat-square)](https://twitter.com/medunes2)
<br>

### How yo use it?

#### To install PHP-SPX for a specific version:

```bash
# needs sudo!
$ ./install.sh <version> <type>
```

* ```<version>```: one of  5.6, 7.1, 7.2, 7.3, 7.4, 8.0 or 8.1"
* ```<type>```: one of  ```fpm``` or ```cli```

#### Examples:

```bash
$ sudo ./setup_spx 7.3 cli
$ sudo ./setup_spx 7.4 fpm
```
