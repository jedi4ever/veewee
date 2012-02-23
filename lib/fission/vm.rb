require 'fission/leasesfile'
require 'shellwords'
require 'fission/error'

module Fission
  class VM
    attr_reader :name

    def initialize(name)
      @name = name
    end

    #####################################################
    # Path Helpers
    #####################################################
    # Returns the topdir of the vm
    def path
      File.join Fission.config.attributes['vm_dir'], "#{@name}.vmwarevm"
    end

    # Returns a string to the path of the config file
    # There is no guarantee it exists
    def vmx_path
      return File.join(path, "#{@name}.vmx")
    end


    ####################################################################
    # State information
    ####################################################################
    def running?
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?

      command = "#{vmrun_cmd} list"
      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus

      if response.successful?
        vms = output.split("\n").select do |vm|
          vm.include?('.vmx') && File.exists?(vm) && File.extname(vm) == '.vmx'
        end
        return vms.include?(self.vmx_path)
      else
        raise Fission::Error,"Error listing the state of vm #{@name}:\n#{output}"
      end
    end

    def suspended?
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?

      suspend_filename=File.join(File.dirname(vmx_path), File.basename(vmx_path,".vmx")+".vmem")
      return File.exists?(suspend_filename)
    end

    # Checks to see if a vm exists
    def exists?
      File.exists? vmx_path
    end

    # Returns the state of a vm
    def state
      return "not created" unless self.exists?

      return "suspend" if self.suspended?

      return "running" if self.running?

      return "not running"
    end

    ####################################################################
    # VM information
    ####################################################################

    # Returns an Array of snapshot names
    def snapshots
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?

      command = "#{vmrun_cmd} listSnapshots #{vmx_path.shellescape} 2>&1"
      output = `#{command}`

      raise "There was an error listing the snapshots of #{@name} :\n #{output}" unless  $?.exitstatus==0

      snaps_unfiltered = output.split("\n").select { |s| !s.include? 'Total snapshots:' }
      snaps=snaps_unfiltered.map { |s| s.strip }
      return snaps
    end

    # Retrieve the first mac address for a vm
    # This will only retrieve the first auto generate mac address
    def mac_address
      raise ::Fission::Error,"VM #{@name} does not exist" unless self.exists?

      line=File.new(vmx_path).grep(/^ethernet0.generatedAddress =/)
      if line.nil?
        #Fission.ui.output "Hmm, the vmx file #{vmx_path} does not contain a generated mac address "
        return nil
      end
      address=line.first.split("=")[1].strip.split(/\"/)[1]
      return address
    end

    # Retrieve the ip address for a vm.
    # This will only look for dynamically assigned ip address via vmware dhcp
    def ip_address
      raise ::Fission::Error,"VM #{@name} does not exist" unless self.exists?

      unless mac_address.nil?
        lease=LeasesFile.new("/var/db/vmware/vmnet-dhcpd-vmnet8.leases").find_lease_by_mac(mac_address)
        if lease.nil?
          return nil
        else
          return lease.ip
        end
      else
        # No mac address was found for this machine so we can't calculate the ip-address
        return nil
      end
    end

    ####################################################################
    # VMS information
    ####################################################################

    # Returns an array of vm objects
    def self.all
      vm_dirs = Dir[File.join Fission.config.attributes['vm_dir'], '*.vmwarevm'].select do |d|
        File.directory? d
      end

      vm_names=vm_dirs.map { |d| File.basename d, '.vmwarevm' }
      vms=[]
      vm_names.each do |vmname|
        vm=Fission::VM.new vmname
        vms << vm
      end

      return vms
    end

    # Returns an array of vms that are running
    def self.all_running
      running_vms=self.all.select do |vm|
        vm.state=="running"
      end
      return running_vms
    end

    # Returns an existing vm
    def self.get(name)
      return Fission::VM.new(name)
    end

    #####################################################
    # VM Class Actions
    #####################################################
    def self.clone(source_vm, target_vm)
      raise Fission::Error,"VM #{source_vm} does not exist" unless Fission::VM.new(source_vm).exists?
      raise Fission::Error,"VM #{target_vm} already exists" if Fission::VM.new(target_vm).exists?

      FileUtils.cp_r Fission::VM.new(source_vm).path, Fission::VM.new(target_vm).path

      rename_vm_files source_vm, target_vm
      update_config source_vm, target_vm

      response = Response.new :code => 0
    end

    def self.delete(vm_name)
      raise Fission::Error,"VM #{vm_name} does not exist" unless Fission::VM.new(vm_name).exists?

      vm=Fission::VM.new(vm_name)
      FileUtils.rm_rf vm.path
      Fission::Metadata.delete_vm_info(vm.path)

      Response.new :code => 0
    end


    #####################################################
    # VM Instance Actions
    #####################################################
    def create_snapshot(name)
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?

      command = "#{vmrun_cmd} snapshot #{vmx_path.shellescape} \"#{name}\" 2>&1"
      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus
      response.output = output unless response.successful?

      response
    end

    def start(args={})
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?
      raise Fission::Error,"VM #{@name} is already started" if self.running?


      command = "#{vmrun_cmd} start #{vmx_path.shellescape}"

      if !args[:headless].blank? && args[:headless]
        command << " nogui 2>&1"
      else
        command << " gui 2>&1"
      end

      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus
      response.output = output unless response.successful?

      response
    end

    def stop
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?
      raise Fission::Error,"VM #{@name} is not running" unless self.running?

      command = "#{vmrun_cmd} stop #{vmx_path.shellescape} 2>&1"
      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus
      response.output = output unless response.successful?

      response
    end

    def halt
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?
      raise Fission::Error,"VM #{@name} is not running" unless self.running?

      command = "#{vmrun_cmd} stop #{vmx_path.shellescape} hard 2>&1"
      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus
      response.output = output unless response.successful?

      response
    end

    def resume
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?
      raise Fission::Error,"VM #{@name} is already running" if self.running?
      if self.suspended?
        self.start
      end
    end

    def suspend
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?
      raise Fission::Error,"VM #{@name} is not running" unless self.running?

      command = "#{vmrun_cmd} suspend #{vmx_path.shellescape} hard 2>&1"
      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus
      response.output = output unless response.successful?
      response
    end

    # Action to revert to a snapshot
    # Returns a response object
    def revert_to_snapshot(name)
      raise Fission::Error,"VM #{@name} does not exist" unless self.exists?

      command = "#{vmrun_cmd} revertToSnapshot #{vmx_path.shellescape} \"#{name}\" 2>&1"
      output = `#{command}`

      response = Fission::Response.new :code => $?.exitstatus
      response.output = output unless response.successful?

      response
    end

    #####################################################
    # Helpers
    #####################################################
    private
    def self.rename_vm_files(from, to)
      to_vm=Fission::VM.new(to)

      files_to_rename(from, to).each do |filename|
        text_to_replace = File.basename(filename, File.extname(filename))

        if File.extname(filename) == '.vmdk'
          if filename.match /\-s\d+\.vmdk/
            text_to_replace = filename.partition(/\-s\d+.vmdk/).first
          end
        end

        unless File.exists?(File.join(to_vm.path, filename.gsub(text_to_replace, to)))
          FileUtils.mv File.join(to_vm.path, filename),
            File.join(to_vm.path, filename.gsub(text_to_replace, to))
        end
      end
    end

    def self.files_to_rename(from, to)
      files_which_match_source_vm = []
      other_files = []

      from_vm=Fission::VM.new(from)

      Dir.entries(from_vm.path).each do |f|
        unless f == '.' || f == '..'
          f.include?(from) ? files_which_match_source_vm << f : other_files << f
        end
      end

      files_which_match_source_vm + other_files
    end

    def self.vm_file_extensions
      ['.nvram', '.vmdk', '.vmem', '.vmsd', '.vmss', '.vmx', '.vmxf']
    end

    # This is done after a clone has been done
    # All files are already at the to location
    # The content of the text files will be substituted with strings from => to
    def self.update_config(from, to)
      to_vm=Fission::VM.new(to)

      ['.vmx', '.vmxf', '.vmdk'].each do |ext|
        file = File.join to_vm.path, "#{to}#{ext}"

        unless File.binary?(file)
          text = (File.read file).gsub from, to
          File.open(file, 'w'){ |f| f.print text }
        end

      end

      # Rewrite vmx file to avoid messages
      new_vmx_file=File.open(File.join(to_vm.vmx_path),'r')

      content=new_vmx_file.read

      # Filter out other values
      content=content.gsub(/^tools.remindInstall.*\n/, "")
      content=content.gsub(/^uuid.action.*\n/,"").strip

      # Remove generate mac addresses
      content=content.gsub(/^ethernet.+generatedAddress.*\n/,"").strip

      # Add the correct values
      content=content+"\ntools.remindInstall = \"FALSE\"\n"
      content=content+"uuid.action = \"create\"\n"

      # Now rewrite the vmx file
      File.open(new_vmx_file,'w'){ |f| f.print content}

    end

    def vmrun_cmd
      return Fission.config.attributes['vmrun_cmd']
    end

  end
end
