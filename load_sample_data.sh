#!/bin/bash

clear

stty erase '^?'

echo -n "Give the installation absolute folder  (e.g. /users/yourname/Sites/magentodemo): "
read rootfolder 

if [ "$rootfolder" = "" ]; then
  echo "no valid root folder was given, stopping the installation..."
  exit
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

if [ -f magento-sample-data-1.2.0.tar.gz ] ; then
  echo "skipping sample data download"
else
  wget http://www.magentocommerce.com/downloads/assets/1.2.0/magento-sample-data-1.2.0.tar.gz
fi
cp magento-sample-data-1.2.0.tar.gz $rootfolder

cd $rootfolder

tar -zxvf magento-sample-data-1.2.0.tar.gz

echo "Moving files..."

mv magento-sample-data-1.2.0/media/* media/
mv magento-sample-data-1.2.0/magento_sample_data_for_1.2.0.sql data.sql

echo "Setting permissions..."

chmod 777 media

echo "Importing sample products..."
echo "Login to the database with your password ..."
mysql -h localhost -u $dbuser -p$dbpass $dbname < data.sql

echo "Cleaning up files..."
echo

rm -rf magento/ magento-sample-data-1.2.0/
rm -rf data.sql
rm -rf magento-sample-data-1.2.0.tar.gz

echo "Sample data imported!"
