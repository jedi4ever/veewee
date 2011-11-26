require 'ostruct'
require 'veewee/provider/core/helper/iso'

module Veewee
  class Definition

    include ::Veewee::Provider::Core::Helper::Iso

    attr_accessor :name
    attr_accessor :env
    attr_accessor :path

    attr_accessor :cpu_count,:memory_size,:iso_file
    attr_accessor :disk_size, :disk_format

    attr_accessor :os_type_id

    attr_accessor :boot_wait,:boot_cmd_sequence

    attr_accessor :kickstart_port,:kickstart_ip,:kickstart_timeout, :kickstart_file

    attr_accessor :ssh_login_timeout, :ssh_user , :ssh_password, :ssh_key, :ssh_host_port, :ssh_guest_port

    attr_accessor :sudo_cmd
    attr_accessor :shutdown_cmd

    attr_accessor :postinstall_files, :postinstall_timeout

    attr_accessor :floppy_files


    attr_accessor :use_hw_virt_ext,:use_pae,:hostiocache

    attr_accessor :iso_dowload_timeout, :iso_src,:iso_md5 ,:iso_download_instructions

    attr_accessor :virtualbox
    attr_accessor :vmfusion
    attr_accessor :kvm

    def initialize(name,path,env)

      @name=name
      @env=env

      if path.nil? 
        @path=File.join(env.definition_dir,name)
      else
        @path=path
      end

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
      @ssh_host_port = "2222"; @ssh_guest_port = "22"
      #        :ssh_host_port => "2222", :ssh_guest_port => "22", :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
      #       :shutdown_cmd => "shutdown -h now",
      #        :kickstart_file => nil,

      @virtualbox={:vm_options => {}}
      @vmfusion={:vm_options => {}}
      @kvm={:vm_options => {}}

    end


    # This function takes a hash of options and injects them into the definition
    def declare(options)
      options.each do |key, value|
        instance_variable_set("@#{key}".to_sym, options[key])
        env.logger.info("definition") { " - #{key} : #{options[key]}" }
      end

    end

    # Class method to loading a definition
    def self.load(name,env)

      # Construct the path to the definition

      path=File.join(env.definition_dir,name)
      definition=Veewee::Definition.new(name,path,env)
      env.logger.info "Loading definition directory #{definition.path}"
      unless definition.exists?
        raise Veewee::DefinitionNotExist,"Error: Definition #{name} does not seem to exist"
      end

      # We create this longer name to avoid clashes
      veewee_definition=definition

      if definition.exists?
        definition_file=File.join(definition.path,"definition.rb")
        content=File.read(definition_file)

        content.gsub!("Veewee::Session.declare","veewee_definition.declare")
        content.gsub!("Veewee::Definition.declare","veewee_definition.declare")

        env.logger.info(content)

        begin
          cwd=FileUtils.pwd
          env.logger.info("Entering path #{definition.path}")
          FileUtils.cd(definition.path)
          self.instance_eval(content)
          env.logger.info("Returning to  path #{cwd}")
          FileUtils.cd(cwd)
        rescue NameError => ex
          raise Veewee::DefinitionError,"NameError reading definition from file #{definition_file} #{ex}"
        rescue Exception => ex
          raise Veewee::DefinitionError,"Error in the definition from file #{definition_file}\n#{ex}"
        end
      else
        env.logger.fatal("#{definition_file} not found")
        raise Veewee::DefinitionNotExist,"#{definition_file} not found"
      end

      if definition.valid?
        return definition
      else
        env.logger.fatal("Invalid Definition")
        raise Veewee::DefinitionError,"Invalid Definition"
      end
    end

    def exists?
      filename=File.join(path,"definition.rb")
      unless File.exists?(filename)
        return false
      end

      return true
    end

    def valid?
      unless exists?
        return false
      end

      unless ostype_valid?
        return false
      end

      return true
    end

    private
    def ostype_valid?
      unless env.ostypes.has_key?(@os_type_id)
        env.logger.info("The ostype: #{@os_type_id} is not available")
        return false
      else
        return true
      end
    end

    def method_missing(m, *args, &block)
      puts "There's no attribute #{m} defined for definition #{@name}-- ignoring it"
    end

  end #End Class
end #End Module
