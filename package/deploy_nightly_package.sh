#!/bin/bash

set -e
export PKG_URL_PREFIX=https://dl.bintray.com/igrr/arduino-esp8266/:
commit=`git rev-parse --short HEAD`

./build_boards_manager_package.sh

ver=`ls -1 versions`
bintray_slug=igrr/arduino-esp8266/arduino-esp8266-core

# Upload to bintray
# URL to the file will look like this: https://dl.bintray.com/igrr/arduino-esp8266/:esp8266-2.4.0-nightly+20170218.zip
curl --progress-bar \
	-T versions/$ver/esp8266-$ver.zip \
	-uigrr:$BINTRAY_API_KEY \
	-o curl.out \
	https://api.bintray.com/content/$bintray_slug/$ver/esp8266-$ver.zip


# Publish the uploaded file
curl -uigrr:$BINTRAY_API_KEY \
	-X POST \
	https://api.bintray.com/content/$bintray_slug/$ver/publish

# Load depoy key
echo -n $ESP8266_ARDUINO_DEPLOY_KEY_B64 > ~/.ssh/esp8266_arduino_deploy_b64
base64 --decode --ignore-garbage ~/.ssh/esp8266_arduino_deploy_b64 > ~/.ssh/esp8266_arduino_deploy
chmod 600 ~/.ssh/esp8266_arduino_deploy
echo -e "Host github.com\n\tStrictHostKeyChecking no\n\tIdentityFile ~/.ssh/esp8266_arduino_deploy" >> ~/.ssh/config

# Clong gh-pages branch
git clone git@github.com:esp8266/Arduino.git --branch gh-pages --single-branch gh-pages
cd gh-pages

# Update package_esp8266com_index.json
cp ../versions/$ver/package_esp8266com_index.json ./
git add package_esp8266com_index.json
git commit -m "Update nightly build to $ver\n\nBUILT_FROM: $commit"
git push origin gh-pages
