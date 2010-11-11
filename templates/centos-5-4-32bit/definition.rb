  	thebox =Veebox.new(vmname, { 
      :dvd => "/Users/patrick/Downloads/CentOS-5.5-i386-bin-DVD/CentOS-5.5-i386-bin-DVD.iso",
      :floppy => "/Users/patrick/Downloads/floppy-ubuntu.img",
      :postinstall => "", 
      :provider => 'vbox', 
      :vm_options => { :ostype => 'RedHat', :memory => '384' , :acpi => 'on',  :ioapic => 'on', :hwvirtex => 'on' , :nestedpaging => 'on'},
      :net_options => {:nic1 => "hostonly", :hostonlyadapter1 => 'vboxnet0' , :nic2 => 'intnet', :intnet2 => "pxenet"},
      :disk_options => {:size => "10240"} ,
      :ssh_options => {:host => "localhost", :host_port => host_port, :guest_port => 22, :user => "root", :password => "pipopo", :timeout => 300000},
      :sudo_options => {:user => "root", :password => "pipopo"},
      :overwrite => true })

      linux text ks=floppy<Enter>
