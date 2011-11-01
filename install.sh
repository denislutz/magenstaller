#!/bin/bash

clear

stty erase '^?'

echo -n "Give the installation absolute folder  (e.g. /users/yourname/Sites/magentodemo): "
read rootfolder 

if [ "$rootfolder" = "" ]; then
  rootfolder="~/Sites/magentodemo"
  echo "installation folder is set to $rootfolder"
fi

echo -n "Give the magento version you want to install  (enter for default 1.6.0.0): "
read magento_version 

if [ "$magento_version" = "" ]; then
  magento_version="1.6.0.0"
  echo "installation folder is set to $magento_version"
fi

echo -n "Database Name (magentodemo is default, press enter): "
read dbname
if [ "$dbname" = "" ]; then
  dbname="magentodemo"
  echo "database name is set to $dbname"
fi

echo -n "Database User (press enter for default 'root'): "
read dbuser
if [ "$dbuser" = "" ]; then
  dbuser="root"
  echo "database name is set to $dbuser"
fi

echo -n "Database Password (press enter for default '': "
read dbpass
if [ "$dbpass" = "" ]; then
  dbpass=""
  echo "dbpass is $dbpass"
fi

echo -n "Admin Password (press enter for default '123pass123'): "
read adminpass
if [ "$adminpass" = "" ]; then
  adminpass="123pass123"
  echo "adminpass is $adminpass"
fi

echo -n "Store URL (default is 127.0.0.1/magentodemo/): "
read url
if [ "$url" = "" ]; then
  url="127.0.0.1/magentodemo/"
  echo "url is $url"
fi

echo -n "Include Sample Data? (y/n) "
read sample

if [ -f magento-$magento_version.tar.gz ]; then
  echo "skipping the download since already downloaded"
else
  echo "Downloading packages..."
  wget http://www.magentocommerce.com/downloads/assets/$magento_version/magento-$magento_version.tar.gz
fi

if [ "$sample" = "y" ]; then
  if [ -f magento-sample-data-1.2.0.tar.gz ] ; then
    echo "skipping sample data download"
  else
    wget http://www.magentocommerce.com/downloads/assets/1.2.0/magento-sample-data-1.2.0.tar.gz
  fi
  cp magento-sample-data-1.2.0.tar.gz $rootfolder
fi

cp magento-$magento_version.tar.gz $rootfolder

cd $rootfolder

echo "Extracting data..."

tar -zxvf magento-$magento_version.tar.gz

if [ "$sample" = "y" ]; then
  tar -zxvf magento-sample-data-1.2.0.tar.gz
fi

echo
echo "Moving files..."
echo

if [ "$sample" = "y" ]; then
  mv magento-sample-data-1.2.0/media/* magento/media/
  mv magento-sample-data-1.2.0/magento_sample_data_for_1.2.0.sql magento/data.sql
fi

mv magento/* magento/.htaccess .

echo
echo "Setting permissions..."
echo

chmod 550 mage

if [ "$sample" = "y" ]; then
  echo
  echo "Importing sample products..."
  echo "Login to the database with your password ..."
  mysql -h localhost -u $dbuser -p$dbpass $dbname < data.sql
fi

echo "Initializing PEAR registry..."

./mage mage-setup .

echo
echo "Cleaning up files..."
echo

if [ "$sample" = "y" ]; then
  rm -rf magento/ magento-sample-data-1.2.0/
  rm -rf data.sql
  rm -rf magento-sample-data-1.2.0.tar.gz
fi

rm -rf magento-$magento_version.tar.gz 
rm -rf index.php.sample .htaccess.sample php.ini.sample *.txt

echo "Installing Magento..."

  php -f install.php -- \
  --license_agreement_accepted "yes" \
  --locale "en_US" \
  --timezone "America/Los_Angeles" \
  --default_currency "USD" \
  --db_host "localhost" \
  --db_name "$dbname" \
  --db_user "$dbuser" \
  --db_pass "$dbpass" \
  --url "$url" \
  --use_rewrites "yes" \
  --use_secure "no" \
  --secure_base_url "" \
  --use_secure_admin "no" \
  --admin_firstname "Store" \
  --admin_lastname "Owner" \
  --admin_email "email@address.com" \
  --admin_username "admin" \
  --admin_password "$adminpass"

echo "+=================================================+"
echo "| MAGENTO LINKS"
echo "+=================================================+"
echo "| Store: $url"
echo "| Admin: ${url}admin/"
echo "+=================================================+"
echo "| ADMIN ACCOUNT"
echo "+=================================================+"
echo "| Username: admin"
echo "| Password: $adminpass"
echo "+=================================================+"
echo "| DATABASE INFO"
echo "+=================================================+"
echo "| Database: $dbname"
echo "| Username: $dbuser"
echo "| Password: $dbpass"
echo "+=================================================+"
