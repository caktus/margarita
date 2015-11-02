#!/bin/bash -ex
rm -rf ~/build_statsd
mkdir ~/build_statsd
cd ~/build_statsd
git clone https://github.com/etsy/statsd.git
cd statsd
dpkg-buildpackage
cd ..
sudo dpkg -i statsd*.deb
cd
rm -rf ~/build_statsd
