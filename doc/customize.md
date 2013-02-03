# Customize Veewee Definitions

## definition.rb

The core definition of a box. All crucial properties are defined here.

The `boot_cmd_sequence` is probably the most interesting because it allows you to override the initial commands
(like keyboard layout) that are fired up in the first boot sequence.

All other settings are used internally by veewee, the virtualization tool or simply for choosing the right ISO:

    Veewee::Definition.declare( {
        :cpu_count => '1',
        :memory_size=> '256',
        :disk_size => '10140',
        :disk_format => 'VDI',
        :disk_variant => 'Standard',
        :os_type_id => 'Ubuntu',
        :iso_file => "ubuntu-12.10-server-i386.iso",
        :iso_src => "http://releases.ubuntu.com/precise/ubuntu-12.10-server-i386.iso",
        :iso_md5 => "3daaa312833a7da1e85e2a02787e4b66",
        :iso_download_timeout => "1000",
        :boot_wait => "10",
        :boot_cmd_sequence => [
            '<Esc><Esc><Enter>',
            '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
            'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
            'hostname=%NAME% ',
            'fb=false debconf/frontend=noninteractive ',
            'console-setup/ask_detect=false console-setup/modelcode=pc105 console-setup/layoutcode=us ',
            'initrd=/install/initrd.gz -- <Enter>'
        ],
        :kickstart_port => "7122",
        :kickstart_timeout => "10000",
        :kickstart_file => "preseed.cfg",
        :ssh_login_timeout => "10000",
        :ssh_user => "vagrant",
        :ssh_password => "vagrant",
        :ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22",
        :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
        :shutdown_cmd => "shutdown -H",
        :postinstall_files => [ "postinstall.sh"],
        :postinstall_timeout => "10000"
    })

IMPORTANT: If you need to change values in the templates, be sure to run `veewee vbox undefine` to remove the old definition and then `veewee vbox define` again to copy the updated template files into the definition.

PRO Tipp: If you change template settings please let us know why. We are very interested in improving the templates.
