module Fission
  class Config

    # Public: Gets/Sets the Hash of attributes.
    attr_accessor :attributes

    # Public: Path to the Fission conf file (default: ~/.fissionrc).
    CONF_FILE = File.expand_path '~/.fissionrc'

    # Public: Initializes a Config object.  This also sets the default config
    # attributes for 'vmrun_bin', 'vmrun_cmd', 'vm_dir', 'plist_file', and
    # 'gui_bin'.
    #
    # Examples
    #
    #   Fission::Config.new
    #
    # Returns a new Config instance.
    def initialize
      @attributes = {}

      @attributes['vm_dir'] = File.expand_path('~/Documents/Virtual Machines.localized/')
      @attributes['lease_file'] = '/var/db/vmware/vmnet-dhcpd-vmnet8.leases'

      fusion_version = :unknown

      if File.exists?("/Library/Application Support/VMware Fusion/vmrun")
        @attributes['vmrun_bin'] = '/Library/Application Support/VMware Fusion/vmrun'
      end

      if File.exists?("/Applications/VMware Fusion.app/Contents/Library/vmrun")  
        @attributes['vmrun_bin'] = "/Applications/VMware Fusion.app/Contents/Library/vmrun"
      end

      if fusion_version == :unknown
      end

      @attributes['plist_file'] = File.expand_path('~/Library/Preferences/com.vmware.fusion.plist')
      @attributes['gui_bin'] = File.expand_path('/Applications/VMware Fusion.app/Contents/MacOS/vmware')

      load_from_file

      @attributes['vmrun_cmd'] = "#{@attributes['vmrun_bin'].gsub(' ', '\ ')} -T fusion"
    end

    # Public: Helper method to access config atributes.  This is a shortcut for
    # querying the config attributes.
    #
    # item - The config item to query.
    #
    # Examples
    #
    #   Fission.config['vmrun_bin']
    #   # => '/foo/bar/vmrun'
    #
    # Returns the value of the specified config item.
    def [](item)
      @attributes[item]
    end

    private
    # Internal: Loads config values from the Fission conf file into attributes.
    #
    # Examples
    #
    #   load_from_file
    #
    # Returns nothing.
    def load_from_file
      if File.file?(CONF_FILE)
        @attributes.merge!(YAML.load_file(CONF_FILE))
      end
    end

  end
end
