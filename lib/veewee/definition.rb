module Veewee
  class Definition

    # This function initializes a Veewee::Definition
    # options match the symbols in the definition.rb file

    def initialize(options)

      defaults={
        :cpu_count => '1', :memory_size=> '256',
        :disk_size => '10240', :disk_format => 'VDI',
        :hostiocache => 'off' ,
        :os_type_id => 'Ubuntu',
        :iso_file => "ubuntu-10.10-server-i386.iso", :iso_src => "",:iso_md5 => "",
        :iso_download_timeout => 1000,
        :boot_wait => "10", :boot_cmd_sequence => [ "boot"],
        :kickstart_port => "7122", :kickstart_ip => "127.0.0.1", :kickstart_timeout => 10000,
        :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22", :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
        :shutdown_cmd => "shutdown -h now",
        :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => 10000,
        :floppy_files => nil,
        :kickstart_file => nil,
        :iso_download_instructions => nil
      }

      options=defaults.merge(options)

      #we need to inject all keys as instance variables & attr_accessors
      options.keys.each do |key|
        instance_variable_set("@#{key.to_s}",options[key])
        # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/41730
        #type.__send__(:attr_accessor,key)
        self.class.send(:attr_accessor,key)
      end

    end

    def self.load(name,definition_dir)
      if self.definition_exists?(name,definition_dir)
        definition_file=File.join(definition_dir,name,"definition.rb")
        begin
          require definition_file
        rescue LoadError
          puts "Error loading definition of #{name}"
          exit
        end
      else
        puts "Error: definition for basebox '#{name}' does not exist."
        exit
      end
      return Veewee::Definition.new(Veewee::Definition.get_loaded_definition)
    end

    #
    @loaded_definitions=nil
    def self.get_loaded_definition
      @loaded_definition
    end

    # For backwards compatible reasons
    # Shoud not be called directly
    def self.declare(options)
      @loaded_definition=options
      return options
    end

    private
    def self.definition_exists?(name,definition_dir)
      if File.directory?(File.join(definition_dir,name))
        if File.exists?(File.join(definition_dir,name,'definition.rb'))
          return true
        else
          return false
        end
      else
        return false
      end
    end

  end #End Class
end #End Module
