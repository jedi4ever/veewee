#! /bin/sh -x

dhclient eth4
ifconfig eth4 | grep addr

