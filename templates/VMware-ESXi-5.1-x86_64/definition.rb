Veewee::Session.declare({
  :cpu_count => '2', :memory_size=> '2048',
  :disk_size => '20140', :disk_format => 'VDI', :hostiocache => 'off', :ioapic => 'on', :pae => 'on',
  :os_type_id => 'ESXi5',
  :iso_file => "VMware-VMvisor-Installer-5.1.0-799733.x86_64.iso",
  :iso_src => "",
  :iso_download_instructions => "- You need to download this manually as there is no automated way to do it\n"+
  "https://my.vmware.com/web/vmware/details?downloadGroup=VCL-VSP510-ESXI-510-EN&productId=285&rPId=3356\n"+
  "Registration is required to complete the download\n"+
  "\n"+
  "- The version tested is 5.1.0 version 799733\n"+
  "- For other versions: changed the iso filename+checksum\n",
  :iso_md5 => "fda2bed9a305b868dcbdc15c6ab6c153",
  :iso_download_timeout => 1000,
  :boot_wait => "15", 
  :boot_cmd_sequence => 
  [ 'O',
    ' ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
    :kickstart_port => "7122", :kickstart_timeout => 300, :kickstart_file => "ks.cfg",
    :ssh_login_timeout => "10000000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
    :ssh_host_port => "7222", :ssh_guest_port => "22",
    :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
    :shutdown_cmd => "poweroff",
    :postinstall_files => ["vagrant_key.py", "vnc_enable.sh" ], :postinstall_timeout => 10000,
    # Enable Hypervisor support to allow 64-bit guest VMs
    :vmfusion => { :vm_options => { 'enable_hypervisor_support' => true,  'download_tools' => false } }
})
