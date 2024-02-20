<h1 align="center">
PHP SPX Installer
    <br>
</h1>

* An installer for [PHP SPX](https://github.com/NoiseByNorthwest/php-spx) profiler, that solves [hopefully] most of the encountered issues and works for all supported versions including cli and fpm</h3>
* It also supports multiple PHP versions on the same machine

[![tests](https://github.com/MedUnes/php-spx-installer/actions/workflows/test.yml/badge.svg?)](https://github.com/MedUnes/php-spx-installer/actions/workflows/test.yml)
[![Author](https://img.shields.io/badge/author-@medunes-blue.svg?style=flat-square)](https://twitter.com/medunes2)
<br>

### How yo use it?

#### To install PHP-SPX for a specific version:

```bash
medunes@medunes:~/$ git clone git@github.com:MedUnes/php-spx-installer.git
medunes@medunes:~/$ cd php-spx-installer

# needs sudo!
medunes@medunes:~/php-spx-installer$ sudo ./install.sh <version> <type>
```

* ```<version>```: one of  5.6, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1 or 8.2
* ```<type>```: one of  ```fpm``` or ```cli```

#### Examples:

```bash
medunes@medunes:~/php-spx-installer$ sudo ./install.sh 7.3 cli
medunes@medunes:~/php-spx-installer$ sudo  ./install.sh 7.4 fpm
```
#### TO-DO:

* The current script only supports Linux Debian, would be nice to add support for further OS/Versions..
