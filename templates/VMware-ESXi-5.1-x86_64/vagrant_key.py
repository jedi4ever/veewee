#!/bin/python

import urllib

vagrant_key = "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"
urllib.urlretrieve( vagrant_key, "/etc/ssh/keys-root/authorized_keys")
