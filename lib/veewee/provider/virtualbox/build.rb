require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/provider/virtualbox/util/create'
require 'veewee/provider/virtualbox/util/snapshots'
require 'veewee/provider/virtualbox/util/transaction'
require 'veewee/provider/virtualbox/util/scancode'

module Veewee
  module Provider
    module Virtualbox

      def build
        options={}
        options = {  "force" => true, "format" => "vagrant", "nogui" => false }.merge(options)

        #Command to execute locally

        ssh_options={ 
          :user => @definition.ssh_user, 
          :port => @definition.ssh_host_port,
          :password => @definition.ssh_password,
          :timeout => @definition.ssh_login_timeout.to_i
        }       

        #Suppress those annoying virtualbox messages
        suppress_messages  

        #Check iso file
        verify_iso(@definition.iso_file)

        vm=VirtualBox::VM.find(@boxname)

        # Discarding save state
        if (!vm.nil? && (vm.saved?))
          puts "Removing save state"
          vm.discard_state
          vm.reload
        end

        # If the box is running shut it down
        if (!vm.nil? && !(vm.powered_off?))
          puts "Shutting down vm #{@boxname}"
          #We force it here, maybe vm.shutdown is cleaner
          begin

            vm.stop
          rescue VirtualBox::Exceptions::InvalidVMStateException
            puts "There was problem sending the stop command because the machine is in an Invalid state"
            puts "Please verify leftovers from a previous build in your vm folder"
            exit
          end
          sleep 3
        end


        if (options["force"]==false)
          puts "The box is already there, we can't destroy it"
        else    
          puts "Forcing build by destroying #{@boxname} machine"
          destroy_vm
        end

        if Veewee::Util::Tcp.is_port_open?("localhost", @definition.ssh_host_port)
          puts "Hmm, the port #{@definition.ssh_host_port} is open. And we shut down?"
          exit
        end


        #checksums=calculate_checksums(@definition,boxname)
        checksums=[ "XXX"]
        #        transaction("0-initial-#{checksums[0]}",checksums) do

        #Create the Virtualmachine and set all the memory and other stuff
        create_vm
        add_shared_folder

        #Create a disk with the same name as the boxname
        create_disk

        #These command actually call the commandline of Virtualbox, I hope to use the virtualbox-ruby library in the future
        add_ide_controller
        add_sata_controller
        attach_disk
        mount_isofile
        add_ssh_nat_mapping
        create_floppy

        #Starting machine

        if (options["nogui"]==true)
          start_vm("vrdp")
        else
          start_vm("gui")
        end

        #waiting for it to boot
        puts "Waiting for the machine to boot"
        sleep @definition.boot_wait.to_i

        send_sequence(@definition.boot_cmd_sequence)

        kickstartfile=@definition.kickstart_file
        if kickstartfile.nil? || kickstartfile.length == 0
          puts "Skipping webserver as no kickstartfile was specified"
        else
          puts "Starting a webserver on port #{@definition.kickstart_port}"
          #:kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 1000,:kickstart_file => "preseed.cfg",
          if kickstartfile.is_a? String
            Veewee::Util::Web.wait_for_request(kickstartfile,{:port => @definition.kickstart_port,
              :host => @definition.kickstart_ip, :timeout => @definition.kickstart_timeout,
              :web_dir => File.join(@environment.definition_dir,@boxname)})
            end 
            if kickstartfile.is_a? Array
              kickstartfiles=kickstartfile
              kickstartfiles.each do |kickfile|
                Veewee::Util::Web.wait_for_request(kickfile,{:port => @definition.kickstart_port,
                  :host => @definition.kickstart_ip, :timeout => @definition.kickstart_timeout,
                  :web_dir => File.join(@environment.definition_dir,@boxname)})
                end
              end
            end




            Veewee::Util::Ssh.when_ssh_login_works("localhost",ssh_options) do
              #Transfer version of Virtualbox to $HOME/.vbox_version            
              versionfile=Tempfile.open("vbox.version")
              versionfile.puts "#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}"
              versionfile.rewind
              begin
                Veewee::Util::Ssh.transfer_file("localhost",versionfile.path,".vbox_version", ssh_options)
              rescue RuntimeError
                puts "error transfering file, possible not enough permissions to write?"
                exit
              end
              puts ""
              versionfile.close
              versionfile.delete
            end

            #            end #initial Transaction


            counter=1
            @definition.postinstall_files.each do |postinstall_file|

              filename=File.join(@environment.definition_dir,@boxname,postinstall_file)   

              #transaction(boxname,"#{counter}-#{postinstall_file}-#{checksums[counter]}",checksums) do

              Veewee::Util::Ssh.when_ssh_login_works("localhost",ssh_options) do
                begin
                  Veewee::Util::Ssh.transfer_file("localhost",filename,File.basename(filename),ssh_options)
                rescue RuntimeError
                  puts "error transfering file, possible not enough permissions to write?"
                  exit
                end
                command=@definition.sudo_cmd
                newcommand=command.gsub(/%p/,"#{@definition.ssh_password}")
                newcommand.gsub!(/%u/,"#{@definition.ssh_user}")
                newcommand.gsub!(/%f/,"#{postinstall_file}")
                puts "***#{newcommand}"
                Veewee::Util::Ssh.execute("localhost","#{newcommand}",ssh_options)
              end

              #end Other Transactions
              counter+=1

            end  

            puts "#{boxname} was build succesfully. "
            puts ""
            puts "Now you can: "
            puts "- verify your box by running              : vagrant basebox validate #{boxname}"
            puts "- export your vm to a .box fileby running : vagrant basebox export   #{boxname}"

          end

          def start_vm(mode)
            vm=VirtualBox::VM.find(@boxname)
            vm.start(mode)
          end

        end #Module
      end #Module
    end #Module