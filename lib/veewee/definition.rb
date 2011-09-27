require 'ostruct'

module Veewee
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
    
    attr_accessor :os_type_id,:use_hw_virt_ext,:use_pae,:hostiocache
    
    attr_accessor :iso_dowload_timeout, :iso_src,:iso_md5 ,:iso_download_instructions
    
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

    end

     
    def method_missing(m, *args, &block)
     env.logger.info "There's no attribute #{m} defined for builder #{@name}-- ignoring it"
    end
    
    def declare(options)      
      options.each do |key, value|
        instance_variable_set("@#{key}".to_sym, options[key])
        env.logger.info("definition") { " - #{key} : #{options[key]}" }
      end 
      verify_ostype
           
    end
    
    # Loading a definition
    def self.load(name,env)

      dir=env.get_definition_paths[name]
      
      if dir.nil?
        env.ui.error "Error loading definition."
        exit -1

     end
      
      veewee_definition=Veewee::Definition.new(name,env)
      veewee_definition.path=dir
      
      definition_file=File.join(dir,"definition.rb")
      if File.exists?(definition_file)
        definition_content=File.read(definition_file)
            
        definition_content.gsub!("Veewee::Session.declare","veewee_definition.declare")
        definition_content.gsub!("Veewee::Definition.declare","veewee_definition.declare")

        env.logger.info(definition_content)

        begin
          cwd=FileUtils.pwd
          FileUtils.cd(dir)
          self.instance_eval(definition_content)
              env.logger.info("Setting definition path for definition #{name} to #{File.dirname(definition_file)}")
              FileUtils.cd(cwd)
            rescue NameError => ex
              env.ui.error("NameError reading definition from file #{definition_file} #{ex}")
            rescue Exception => ex
              env.ui.error("Error in the definition from file #{definition_file}\n#{ex}")
              exit -1
            end
          else
            env.logger.info "#{definition_file} not found"
          end
        veewee_definition
    end
    
    def verify_ostype

      unless env.config.ostypes.has_key?(@os_type_id)
        raise "The ostype: #{@os_type_id} is not available"
      end

    end


  end #End Class
end #End Module
