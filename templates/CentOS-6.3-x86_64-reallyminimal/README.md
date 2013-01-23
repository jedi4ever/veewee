# CentOS 6.3 VirtualBox image for Vagrant

`CentOS release 6.3 (Final)`

Small as I can make it (which doesn't mean it can't be made smaller…)

* All upgrades, as of 2013-Jan-02.  
* Puppet 3.0.2 from the Puppet Labs Yum repo
* Chef 10.16.4 via `gem install chef`
* VirtualBox Guest Additions 4.2.6
* EPEL only used for `dkms`, to make VBox Guest Additions survive kernel upgrades (hopefully)
* EPEL and Puppet Labs Yum repositories removed after install
