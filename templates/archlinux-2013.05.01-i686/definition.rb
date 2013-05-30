Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '512',
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'ArchLinux',
  :iso_file => "archlinux-2013.05.01-dual.iso",
  :iso_src => "http://archlinux.puzzle.ch/iso/2013.05.01/archlinux-2013.05.01-dual.iso",
  :iso_md5 => "77e66f400dcb044f9e5c2b440cf4878a",
  :iso_download_timeout => "10000",
  :boot_wait => "5", :boot_cmd_sequence => [
    '<Down>', # move to the 32 bit version
    '<Wait>', '<Enter>', # start install
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    'gdisk /dev/sda<Enter>', # start partioning
      # boot partition
      'n<Enter>', # new partition
      '<Enter>',  # default partition number
      '<Enter>', # not at beginning
      '250m<Enter>', # at the end
      '<Enter>', # default filesystem
      # swap partition
      'n<Enter>', # new partition
      '<Enter>',  # default partition number
      '<Enter>', # not at beginning
      '512m<Enter>', # at the end
      '8200<Enter>', # swap filesystem
      # root partition
      'n<Enter>', # new partition
      '<Enter>',  # default partition number
      '<Enter>', # not at beginning
      '<Enter>', # all space thats left by default
      '<Enter>', # default filesystem
      'w<Enter>', # write and exit gdisk
      'y<Enter>', # confirm

    'mkfs.ext4 /dev/sda1<Enter>', # make boot filesystem
    'mkswap /dev/sda2<Enter>', # make swap filesystem
    'mkfs.ext4 /dev/sda3<Enter>', # make root filesystem
    'swapon /dev/sda2<Enter>', # enable swap 
    'mount /dev/sda3 /mnt<Enter>', # mount root 
    'mkdir /mnt/boot<Enter>','mount /dev/sda1 /mnt/boot<Enter>', # mount boot
    'wget -O - http://%IP%:%PORT%/install.sh | bash<Enter>',
  ],
  :kickstart_port => "7122", :kickstart_timeout => "1000", :kickstart_file => "install.sh",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -h now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
