require 'socket'
require 'net/scp'

module Veewee
  class Session
    
      attr_accessor :veewee_dir
      attr_accessor :definition_dir
      attr_accessor :template_dir
      attr_accessor :iso_dir
      attr_accessor :name
      attr_accessor :definition

    def self.setenv(env)
      @veewee_dir=env[:veewee_dir]
      @definition_dir=env[:definition_dir]
      @template_dir=env[:template_dir]
      @box_dir=env[:box_dir]
      @iso_dir=env[:iso_dir]
    end
 
    def self.declare(options)
      defaults={
        :cpu_count => '1', :memory_size=> '256', 
        :disk_size => '10140', :disk_format => 'VDI',:disk_size => '10240' ,
        :os_type_id => 'Ubuntu',
        :iso_file => "ubuntu-10.10-server-i386.iso", :iso_src => "", :iso_md5 => "", :iso_download_timeout => 1000,
        :boot_wait => "10", :boot_cmd_sequence => [ "boot"],
        :kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 10000,:kickstart_file => "preseed.cfg",
        :ssh_login_timeout => "100",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22",
        :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => 10000}
        
        @definition=defaults.merge(options)
 
    end
    
    def self.define(boxname,template_name)
      #Check if template_name exists
      #puts @veewee_dir
      if File.directory?(File.join(@template_dir,template_name))
      else
        puts "this template can not be found, use rake templates to list all templates"
      end
      if File.directory?(File.join(@definition_dir,boxname))
        puts "this definition already exists, use rake undefine['#{name}'] to remove this definition"
      else
        FileUtils.mkdir(File.join(@definition_dir,boxname))
        FileUtils.cp_r(File.join(@template_dir,template_name,'.'),File.join(@definition_dir,boxname))
        puts "template succesfully copied"
      end
    end

  
    def self.definition_exists?(boxname)
      if File.directory?(File.join(@definition_dir,boxname))
        if File.exists?(File.join(@definition_dir,boxname,'definition.rb'))
          return true
        else
           return false
        end
      else
        return false
      end
              
    end

    def self.undefine(boxname)
      name_dir=File.join(@definition_dir,boxname)
      if File.directory?(name_dir)
        #TODO: Needs to be more defensive!!
        FileUtils.rm_rf(name_dir)
      else
        puts "Can not undefine , definition #{boxname} does not exist"
        exit
      end
    end

    def self.list_templates
      puts "the following templates are available:"
      subdirs=Dir.glob("#{@template_dir}/*")
      subdirs.each do |sub|
        if File.directory?("#{sub}")
          definition=Dir.glob("#{sub}/definition.rb")
          if definition.length!=0
            name=sub.sub(/#{@template_dir}\//,'')
            puts "use rake define['<boxname>','#{name}']"
          end
        end
      end
    end

    def self.list_boxes
        puts "Not yet implemented"
    end

    def self.list_definitions
        puts "Not yet implemented"
    end

    def self.clean
        puts "Not yet implemented"
    end

    def self.remove_box(boxname)
        puts "Not yet implemented"
    end

    def self.build(boxname)
      #Now we have to load the definition



       if definition_exists?(boxname)
        definition_file=File.join(@definition_dir,boxname,"definition.rb")
        begin
          require definition_file
        rescue LoadError
          puts "Error loading definition of #{boxname}"
          exit
        end    

        #Command to execute locally
        vboxcmd="VboxManage"
          
        
        #TODO Check all parameters for correctness

        vm=VirtualBox::VM.find(boxname)
        if vm.nil?

          #TODO One day ruby-virtualbox will be able to handle this creation
          #Box does not exist, we can start to create it
          command="#{vboxcmd} createvm --name '#{boxname}' --ostype '#{@definition[:os_type_id]}' --register"    
          
          #Exec and system stop the execution here
          IO.popen("#{command}") { |f| puts f.gets }
          vm=VirtualBox::VM.find(boxname)
        else
          puts "box already exists"
        end
        
        if (!vm.nil? && !(vm.powered_off?))
            puts "shutting down box"
            #We force it here, maybe vm.shutdown is cleaner
            vm.stop
        end     
  
        #Set all params we know 
        vm.memory_size=@definition[:memory_size].to_i
        vm.os_type_id=@definition[:os_type_id]
        vm.cpu_count=@definition[:cpu_count].to_i
        vm.name=boxname

        vm.validate
        vm.save

        #Now check the disks
        #Maybe one day we can use the name, now we have to check location
        #disk=VirtualBox::HardDrive.find(boxname)
        disk=nil
        location=boxname+"."+@definition[:disk_format].downcase
               
        VirtualBox::HardDrive.all.each do |d|
          if !d.location.match(/#{location}/).nil?
            disk=d
          end
        end   
        
        puts "hea"
        if disk.nil?
          puts "creating new harddrive"
          newdisk=VirtualBox::HardDrive.new
          newdisk.format=@definition[:disk_format]
          newdisk.logical_size=@definition[:disk_size].to_i

          newdisk.location=location
          newdisk.save
          disk=newdisk
          puts disk              
        end
        
        #unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
        command ="#{vboxcmd} storagectl '#{boxname}' --name 'IDE Controller' --add ide"
        IO.popen("#{command}") { |f| puts f.gets }

        #unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
        command ="#{vboxcmd} storagectl '#{boxname}' --name 'SATA Controller' --add sata"
        IO.popen("#{command}") { |f| puts f.gets }
        
        puts "here"
        #command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
        command ="#{vboxcmd} storageattach '#{boxname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{location}'"
        IO.popen("#{command}") { |f| puts f.gets }

        full_iso_file=File.join(@iso_dir,@definition[:iso_file])
        puts "#{full_iso_file}"
        #command => "${vboxcmd} storageattach '${vname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '${isodst}' ";
        command ="#{vboxcmd} storageattach '#{boxname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '#{full_iso_file}'"
        puts command
        IO.popen("#{command}") { |f| puts f.gets }
        
        
        #Setting this annoying messages to register
        VirtualBox::ExtraData.global["GUI/RegistrationData"]="triesLeft=0"
        VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, 2009-09-20"
        VirtualBox::ExtraData.global["GUI/SuppressMessages"]="confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff"
        VirtualBox::ExtraData.global["GUI/UpdateCheckCount"]="60"
        update_date=Time.now+86400
        VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, #{update_date.year}-#{update_date.month}-#{update_date.day}, stable"
        
        VirtualBox::ExtraData.global.save
        
        #Map SSH Ports
        #			command => "${vboxcmd} modifyvm '${vname}' --natpf1 'guestssh,tcp,,${hostsshport},,${guestsshport}'",
        port = VirtualBox::NATForwardedPort.new
        port.name = "guestssh"
        port.guestport = @definition[:ssh_guest_port].to_i
        port.hostport = @definition[:ssh_host_port].to_i
        vm.network_adapters[0].nat_driver.forwarded_ports << port
        port.save
        vm.save
        
        #Starting machine
        #vm.start("vrdp")
        vm.start("gui")
        
        #waiting for it to boot
        sleep @definition[:boot_wait].to_i
        
        puts "sending keys"
        Veewee::Scancode.send_sequence("#{vboxcmd}","#{boxname}",@definition[:boot_cmd_sequence])
        
        #:kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 1000,:kickstart_file => "preseed.cfg",
        Veewee::Web.wait_for_request(@definition[:kickstart_file],{:port => @definition[:kickstart_port],
                                  :host => @definition[:kickstart_ip], :timeout => @definition[:kickstart_timeout],
                                  :web_dir => File.join(@definition_dir,boxname)})

        
        Veewee::Ssh.when_ssh_login_works("localhost",{:port => @definition[:ssh_host_port], :user => @definition[:ssh_user],:password => @definition[:ssh_password]}) do

               postinstall_file=File.join(@definition_dir,boxname,@definition[:postinstall_files][0])
               Net::SSH.start( "localhost", @definition[:ssh_user], {:port => @definition[:ssh_host_port], :password => @definition[:ssh_password]} ) do |ssh|
                 puts "Transferring #{postinstall_file} "
                  ssh.scp.upload!( postinstall_file, '.' ) do |ch, name, sent, total|
                    print "\r#{postinstall_file}: #{(sent.to_f * 100 / total.to_f).to_i}%"
                  end
                end

                Net::SSH.start( "localhost", @definition[:ssh_user], {:port => @definition[:ssh_host_port], :password => @definition[:ssh_password]} ) do |session|


                  session.open_channel do |channel|

                     channel.request_pty do |ch, success| 
                       raise "Error requesting pty" unless success 

                       ch.send_channel_request("shell") do |ch, success| 
                         raise "Error opening shell" unless success  
                       end  
                     end

                     channel.on_data do |ch, data|
                       STDOUT.print data

                     end 

                     channel.on_extended_data do |ch, type, data|
                       STDOUT.print "Error: #{data}\n"
                     end

                     channel.send_data( "echo \"vagrant\"|sudo -S sh #{@definition[:postinstall_files][0]}\n" )

                   end

                end

            end
        
      end
    end
  
    def self.local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end

  end
end