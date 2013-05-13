#!/bin/bash
source /etc/profile

# use ruby 1.9
echo RUBY_TARGETS="ruby19" >> /etc/portage/make.conf

echo dev-util/ragel ~$build_arch >> /etc/portage/package.keywords

env-update && source /etc/profile
emerge --autounmask-write --nospinner ruby:1.9
eselect ruby set ruby19
