ENV['GEM_PATH']=File.dirname(__FILE__)
ENV['GEM_HOME']=File.dirname(__FILE__)
ENV['VBOX_USER_HOME']=File.dirname(__FILE__)+"/tmp"
#PATH=$GEM_HOME/bin:$PATH

require 'webrick'
include WEBrick

exit

class Veewee

	#:vostype -> this is the virtualbox type
	#
	def self.contract(options={:vcpu => '1', :vmemory=> '348', :vdisksize => '10140', :isodst => "", :isosrc => "", :isomd5 => "", :bootwait => "30", 
			:vostype => "Ubuntu", :bootcmd => "", :kickport => "", :kickip => "", :vmname => "ubuntu", :hostsshport => "2222", :guestsshport => "22"})
		puts "it works"

    #Download iso file is not existing
    
    #Verify the md5
		if [ options[:isomd5] != ""]
			puts "we go an isomd5"
			verify_md5(options[:isodst],options[:isomd5])
		end

    #Check if exists (remove if wanted)
	  #Create VM unless exits
	  #Add IDE unless exists
	  #Add SATA unless exists
	  #Create Disk unless exists
	  #Add Disk to SATA unless already linked
	  #Add ISO to IDE unless already mounted
	  #Boot VM unless already booted
	  #Wait some time
	  #Send some keystrokes unless ssh exists
	  #Wait for SSH to become alive
	  #Login to the box with username, password
	    #sudo install a minimal chef thing  (rvm?)
	    #or example a script as root to care of the minimal fixing
	  #If installed and checks are running
	    #export the box
		
	end

	def self.verify_md5(filename,checksum)
		puts "verifying md5 sum"
	end

	def self.checkiso_exists(filename)
		puts "verifying if iso exists"
		puts "potentional ask it to download iso, if ask"
	end

	def self.install_gems
		#install vagrant gem
		#install md5sum? gem
		#install virtualbox gem
	end
	
	def self.find_vbox_cmd
		#vboxheadless="VBoxHeadless"
		return "VBoxManage"
	end

	def self.create_vm(options)
		#command => "${vboxcmd} createvm --name ${vmname} --ostype ${vostype} --register",
		#unless => "${vboxcmd} list vms|grep ${vname}"
	end
	
	def self.create_disk(options)
		#command => "${vboxcmd} createhd --filename '${vname}.vdi' --size ${vdisksize}",
		#unless => "${vboxcmd} showhdinfo '${vname}.vdi'"
	end

	def self.create_ide(vmname)
		#command => "${vboxcmd} storagectl '${vname}' --name 'IDE Controller' --add ide",
		#unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
	end

	def self.attach_disk(vmname)
		#command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
	end

	def self.mount_iso(vmname,isofile)
		#command => "${vboxcmd} storageattach '${vname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '${isodst}' ";
	end
	
	def self.create_sata
		#command => "${vboxcmd} storagectl '${vname}' --name 'SATA Controller' --add sata",
		#unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
	end
	
	def self.suppress
    #				command => "${vboxcmd} setextradata global 'GUI/RegistrationData' 'triesLeft=0'; 
    #					${vboxcmd} setextradata global 'GUI/UpdateDate' '1 d, 2009-09-20';	
    #					${vboxcmd} setextradata global 'GUI/SuppressMessages' 'confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff';

	end
	
	def self.set_ssh_port
	  #	exec {
    #		"set ssh port":
    #			command => "${vboxcmd} modifyvm '${vname}' --natpf1 'guestssh,tcp,,${hostsshport},,${guestsshport}'",
    #			unless => "${vboxcmd} showvminfo '${vname}'|grep State|grep running"
    #	}
  end
	
	def self.wait_for_http(filename,options => {:port => 7777})
  end
	
	def self.wait_for_ssh
  end
	
end

Veewee.contract

exit



class FileServlet < WEBrick::HTTPServlet::AbstractServlet
        def do_GET(request,response)
                response['Content-Type']='text/plain'
                response.status = 200
                displayfile=File.open("/Users/patrick/vagrantbox/files/preseed.cfg",'r')
                content=displayfile.read()
                response.body=content
                sleep 4
                @@s.shutdown
        end
end

@@s= HTTPServer.new(:Port => 7125)
@@s.mount("/preseed.cfg", FileServlet)
trap("INT"){@@s.shutdown}
@@s.start

	
