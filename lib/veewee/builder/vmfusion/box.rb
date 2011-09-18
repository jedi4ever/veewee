require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/box'

require 'veewee/builder/vmfusion/helper/console_type'

require 'veewee/builder/vmfusion/helper/buildinfo'
require 'veewee/builder/vmfusion/helper/template'

require 'veewee/builder/vmfusion/assemble'
require 'fission'

require 'veewee/builder/vmfusion/export_ova'


module Veewee
  module Builder
    module Vmfusion
      class Box < Veewee::Builder::Core::Box
        
        def initialize(env,name)
          super(env,name)
        end

        def create_disk
          #Disk types:
          #    0                   : single growable virtual disk
          #    1                   : growable virtual disk split in 2GB files
          #    2                   : preallocated virtual disk
          #    3                   : preallocated virtual disk split in 2GB files
          #    4                   : preallocated ESX-type virtual disk
          #    5                   : compressed disk optimized for streaming
          #    6                   : thin provisioned virtual disk - ESX 3.x and above
          disk_type=1
          current_dir=FileUtils.pwd
          FileUtils.chdir(vm_path)
          command="#{fusion_path.shellescape}/vmware-vdiskmanager -c -s #{@definition.disk_size}M -a lsilogic -t #{disk_type} #{@box_name}.vmdk"
          Veewee::Util::Shell.execute(command)
          FileUtils.chdir(current_dir)
        end
        
        def create_vm
          FileUtils.mkdir_p(vm_path)
          current_dir=FileUtils.pwd
          FileUtils.chdir(vm_path)
          aFile = File.new(vmx_file_path, "w")
          aFile.write(vmx_template)
          aFile.close
          FileUtils.chdir(current_dir)
        end

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        def ssh_options
          ssh_options={
            :user => @definition.ssh_user,
            :port => 22,
            :password => @definition.ssh_password,
            :timeout => @definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end

        def is_running?
          return @raw.ready?
        end
        
        def mac_address
          unless File.exists?(vmx_file_path)
            return nil
          else
            line=File.new(vmx_file_path).grep(/^ethernet0.generatedAddress =/)
            if line.nil?
              puts "Hmm, the vmx files is not valid"
              raise "invalid vmx file #{vmx_file_path}"
            end
            address=line.first.split("=")[1].strip.split(/\"/)[1]
            return address
          end
        end

        def ip_address
        end

        def console_type(sequence,type_options={})
          sequence.each { |s|
            s.gsub!(/%IP%/,Veewee::Util::Tcp.local_ip);
            s.gsub!(/%PORT%/,@definition.kickstart_port);
            s.gsub!(/%NAME%/, @box_name);
          }
          vnc_type(sequence,"localhost",20)
        end
        
        def raw
          @raw=::Fission::VM.new(name)
        end

        def exists?
        end


        def start(mode)
          #mode can be gui or nogui
           raw.start unless raw.nil?
        end

        def stop()
          raw.stop unless raw.nil?
        end

        def halt()
          raw.halt unless raw.nil?
        end


      end # End Class
    end # End Module
  end # End Module
end # End Module
