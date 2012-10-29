Changelog
  now has include-postinstall, exclude-postinstall
  now has pre_postinstall_file allowing pre postinstall execution (ie to export http_proxy, https_proxy)
  ostypes are now synchronized accross kvm
  require libvirt 0.8+ version 
  user veewee instead of vagrant
  veewee::session.declare / not veewee.defintion...
  veewee subcommand compared to vagrant subcommand
  veewee ssh
  veewee start/stop
  veewee steps (username,password, + VEEWEE env variables)

Todo:
  validate vms - + features selection
  check libvirt version
  windows test
  validation of checks (also - include/exclude)
  check execs with exit code
  multinetwork card 
  dkms for kernel installs
