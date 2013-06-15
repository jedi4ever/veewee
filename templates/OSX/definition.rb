Veewee::Definition.declare({
  :cpu_count => '1',
  :memory_size=> '2048',
  :disk_size => '40000',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  # Currently supported os_type_ids: Darwin_10_7, Darwin_10_7_64, Darwin_10_8_64
  :os_type_id => 'Darwin_10_8_64',
  # iso_file must be the output of the prepare_veewee_iso.sh script included with this template,
  # which modifies an installer downloaded from the Mac App Store for a fully-automated install
  :iso_file => "%OSX_ISO%",
  :iso_download_timeout => "1000",
  :boot_wait => "60",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -h now",
  :postinstall_files => [
    "postinstall.sh",           # Base configuration (vagrant user, keys, guest OS tools, etc.)
    "xcode-cli-tools.sh",     # Xcode CLI tools
    # "rvm.bash",               # RVM (not using to allow chef/puppet to use system Ruby by default)
    "chef-omnibus.sh",        # Chef Omnibus install
    "puppet.sh",               # Puppet install from Hashicorp's puppet-boostrap repo
    "fix_user_perms.sh"        # some folders in vagrant's got created as root in the above script
  ],
  :postinstall_timeout => "10000"
})
