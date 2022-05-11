#!/bin/bash

function printUsage() {
  echo -e "PHP-SPX profiler installer. needs sudo!"
  echo -e "usage sudo ./install.sh <version> <type>"
  echo -e "\t <version>: one of  5.6, 7.1, 7.2, 7.3, 7.4, 8.0 or 8.1"
  echo -e "\t <type>: one of  fpm or cli"
  echo -e "Ex1: sudo ./setup_spx 7.3 cli"
  echo -e "Ex2: sudo ./setup_spx 7.4 fpm"
}

PHP_VERSION=$1
PHP_TYPE=$2

if [ -z "$1" ]; then
  echo -e "no php version provided, aborting!"
  printUsage
  exit 1
fi

if [ -z "$2" ]; then
  echo -e "no php type provided, aborting!"
  printUsage
  exit 1
fi

PHP_INI_DIR="/etc/php/${PHP_VERSION}/${PHP_TYPE}"
PHP_BIN="php${PHP_VERSION}"
PHP_EXTENSION_DIR=$($PHP_BIN -i | grep extension_dir | cut -d " " -f 5)

rm -rf "${PHP_INI_DIR}/conf.d/20-spx.ini"
rm -rf "${PHP_EXTENSION_DIR}/spx.so"

apt remove -y "php${PHP_VERSION}-dev"
apt autoremove -y

apt update
apt install -y "php${PHP_VERSION}-dev"

rm -rf ./php-spx

git clone https://github.com/NoiseByNorthwest/php-spx.git
cd "php-spx" || exit 1
git checkout release/latest

make distclean
phpize${PHP_VERSION} –clean
./configure "--with-php-config=/usr/bin/php-config${PHP_VERSION}"
make

rm -rf "${PHP_EXTENSION_DIR}/spx.so" "${PHP_EXTENSION_DIR}/spx.la"
chmod 644 ./modules/spx.so
cp ./modules/spx.so ./modules/spx.la "${PHP_EXTENSION_DIR}"
ls -al "${PHP_EXTENSION_DIR}/spx.so"
echo "process.dumpable = yes" >>"${PHP_INI_DIR}/php.ini"
touch "${PHP_INI_DIR}/conf.d/20-spx.ini"

if [ $PHP_TYPE == "fpm" ]; then
  systemctl restart php${PHP_VERSION}-fpm
fi

rm -rf ./php-spx

echo -e "PHP SPX Profiler successfully installed for php$PHP_VERSION-$PHP_TYPE."
echo -e "Please refer to https://github.com/NoiseByNorthwest/php-spx for how to use it."

