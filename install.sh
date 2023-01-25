#!/bin/bash

##############
# display help
##############

function printUsage() {
  echo -e "PHP-SPX profiler installer. needs sudo!"
  echo -e "usage sudo ./install.sh <version> <type>"
  echo -e "\t <version>: one of  5.6, 7.1, 7.2, 7.3, 7.4, 8.0 or 8.1"
  echo -e "\t <type>: one of  fpm or cli"
  echo -e "Ex1: sudo ./setup_spx 7.3 cli"
  echo -e "Ex2: sudo ./setup_spx 7.4 fpm"
}

############################
# validate input arguments
############################

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
if [ groups $(whoami) | grep -vq sudo ] && [ groups $(whoami) | grep -vq root ]; then
    echo -e "This script requires sudo permissions, aborting!"
    printUsage
    exit 1
fi

PHP_VERSION=$1
PHP_TYPE=$2

############################
# find the correct paths
############################

PHP_INI_DIR="/etc/php/${PHP_VERSION}/${PHP_TYPE}"
PHP_BIN="php${PHP_VERSION}"
PHP_EXTENSION_DIR=$($PHP_BIN -i | grep extension_dir | cut -d " " -f 5)

##########################################
# cleanup any [eventual] old setups
##########################################

rm -rf "${PHP_INI_DIR}/conf.d/20-spx.ini"
rm -rf "${PHP_EXTENSION_DIR}/spx.so"

apt remove -y "php${PHP_VERSION}-dev"
apt autoremove -y

apt update
apt install -y "php${PHP_VERSION}-dev zlib1g-dev"

rm -rf ./php-spx

##########################################
# Clone PHP-SPX, latest version
##########################################

git clone https://github.com/NoiseByNorthwest/php-spx.git
cd "php-spx" || exit 1
git checkout release/latest

########################################################
# Build PHP-SPX with the correct current PHP configs
########################################################

make distclean
phpize${PHP_VERSION} –clean
./configure "--with-php-config=/usr/bin/php-config${PHP_VERSION}"
make

########################################################
# Move built modules to the corresponding paths
########################################################
rm -rf "${PHP_EXTENSION_DIR}/spx.so" "${PHP_EXTENSION_DIR}/spx.la"
chmod 644 ./modules/spx.so ./modules/spx.la
cp ./modules/spx.so ./modules/spx.la "${PHP_EXTENSION_DIR}"
rm -rf ./modules/spx.so ./modules/spx.la
ls -al "${PHP_EXTENSION_DIR}/spx.so"

########################################################
# Create PHP-SPX extension INI file
########################################################
touch "${PHP_INI_DIR}/conf.d/20-spx.ini"
echo "extension=${PHP_EXTENSION_DIR}/spx.so" >"${PHP_INI_DIR}/conf.d/20-spx.ini"
echo "process.dumpable = yes" >>"${PHP_INI_DIR}/php.ini"

########################################################
# Eventually restart the FPM
########################################################
if [ $PHP_TYPE == "fpm" ]; then
  systemctl restart php${PHP_VERSION}-fpm
fi

########################################################
# And we are done
########################################################

rm -rf ./php-spx
echo -e "PHP SPX Profiler successfully installed for php$PHP_VERSION-$PHP_TYPE."
echo -e "Please refer to https://github.com/NoiseByNorthwest/php-spx for how to use it."

