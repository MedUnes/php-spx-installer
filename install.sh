#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

##############
# display help
##############

function printUsage() {
  echo -e "PHP-SPX profiler installer. needs sudo!"
  echo -e "usage sudo ./install.sh <version> <type>"
  echo -e "\t <version>: one of  5.6, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1 or 8.2"
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
hasRoot=$( groups $(whoami) | grep  'root\|sudo')
if [ -z "${hasRoot}" ]; then
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
PHP_EXTENSION_DIR=$(php${PHP_VERSION} -i | grep extension_dir | cut -d " " -f 5)

######## BUILD ARGUMENTS###########
#>>>> PHP_VERSION
#>>>> PHP_TYPE
#>>>> PHP_INI_DIR
#>>>> PHP_BIN
#>>>> PHP_EXTENSION_DIR
###################################

echo "started building using:"
echo "PHP_VERSION=$PHP_VERSION"
echo "PHP_TYPE=$PHP_TYPE"
echo "PHP_INI_DIR=$PHP_INI_DIR"
echo "PHP_BIN=$PHP_INI_DIR"
echo "PHP_EXTENSION_DIR=$PHP_INI_DIR"

##########################################
# cleanup any [eventual] old setups
##########################################

rm -rf "${PHP_INI_DIR}/conf.d/20-spx.ini"
rm -rf "${PHP_EXTENSION_DIR}/spx.so"

apt remove -y "php${PHP_VERSION}-dev"
apt autoremove -y

apt update
apt install -y make git "php${PHP_VERSION}-dev" "zlib1g-dev"

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
echo "extension=${PHP_EXTENSION_DIR}/spx.so" > "${PHP_INI_DIR}/conf.d/20-spx.ini"
echo "process.dumpable = yes" >> "${PHP_INI_DIR}/php.ini"
echo "spx.http_enabled=1" >> "$PHP_INI_DIR/conf.d/20-spx.ini"
echo "spx.http_key="dev"" >> "$PHP_INI_DIR/conf.d/20-spx.ini"
echo 'spx.http_ip_whitelist="*"' >> "$PHP_INI_DIR/conf.d/20-spx.ini"

########################################################
# Eventually restart the FPM
########################################################
if [ $PHP_TYPE == "fpm" ]; then
  if [ $(ps --no-headers -o comm 1) == "systemd" ]; then
    systemctl restart php${PHP_VERSION}-fpm
  fi
fi

########################################################
# And we are done
########################################################

rm -rf ./php-spx
echo -e "PHP SPX Profiler successfully installed for php ${PHP_TYPE} ${PHP_VERSION}. Checking the extension from the loaded modules.."
if [ ${PHP_TYPE} == "fpm" ]
then
  "php-${PHP_TYPE}${PHP_VERSION}" -m | grep SPX
else
  "php${PHP_VERSION}" -m | grep SPX
fi

echo -e "Please refer to https://github.com/NoiseByNorthwest/php-spx for how to use it."

