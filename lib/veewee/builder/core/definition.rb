require 'ostruct'

module Veewee::Builder
  module Core
  class Definition

    attr_accessor :name
    attr_accessor :env
    
    attr_accessor :cpu_count,:memory_size,:iso_file
    attr_accessor :disk_size, :disk_format
    
    attr_accessor :os_typ_id
    
    attr_accessor :boot_wait,:boot_cmd_sequence
    
    attr_accessor :kickstart_port,:kickstart_ip,:kickstart_timeout, :kickstart_file

    attr_accessor :ssh_login_timeout, :ssh_user , :ssh_password, :ssh_key, :ssh_host_port, :ssh_guest_port 
    
    attr_accessor :sudo_cmd
    attr_accessor :shutdown_cmd

    attr_accessor :postinstall_files, :postinstall_timeout
    
    attr_accessor :floppy_files
    
    attr_accessor :path

    def initialize(name,env)

      @name=name
      @env=env

      # Default is 1 CPU + 256 Mem of memory
      @cpu_count='1' ; @memory_size='256';      
      
      # Default there is no ISO file mounted
      @iso_file = nil, @iso_src = nil ; @iso_md5 = nil ; @iso_download_timeout=1000 ; @iso_download_instructions = nil
      
      # Default is no floppy mounted
      @floppy_files = nil
      
      # Default there are no post install files
      @postinstall_files=[]; @postinstall_timeout = 10000;

      @iso_file=""
      @disk_size = '10240'; @disk_format = 'VDI'

#        :hostiocache => 'off' ,
#        :os_type_id => 'Ubuntu',


#        :boot_wait => "10", :boot_cmd_sequence => [ "boot"],
#        :kickstart_port => "7122", :kickstart_ip => "127.0.0.1", :kickstart_timeout => 10000,#

#        :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
#        :ssh_host_port => "2222", :ssh_guest_port => "22", :sudo_cmd => "echo '%p'|sudo -S sh '%f'",

#       :shutdown_cmd => "shutdown -h now",


#        :kickstart_file => nil,

#      }

#      options=defaults.merge(options)


    end
    
    def method_missing(m, *args, &block)
     env.logger.info "There's no attribute #{m} defined for builder #{@name}-- ignoring it"
    end


  end #End Class
end #End Module
end #End Module
