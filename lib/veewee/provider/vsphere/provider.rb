require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Vsphere
      class Provider < Veewee::Provider::Core::Provider

        attr_reader :vsphere_server
        attr_reader :vsphere_user
        attr_reader :vsphere_password

        #include ::Veewee::Provider::Vsphere::ProviderCommand
        def initialize(name, options, env)
          super(name, options, env)
        end

        def check_requirements
          #Retrieve credentials for VMware Host
          # Credentials are used in this order
          #   Command Line
          #   ENV File
          @vsphere_server = options['vsphere_server']
          @vsphere_user = options['vsphere_user']
          @vsphere_password = options['vsphere_password']

          cred_path = ENV["VEEWEE_VSPHERE_AUTHFILE"]
          unless cred_path.nil?
            env.logger.info "Reading credentials yamlfile #{cred_path}"
            credentials=YAML.load_file(cred_path)

            @vsphere_server   ||= credentials["vsphere_server"]
            @vsphere_user     ||= credentials["vsphere_user"]
            @vsphere_password ||= credentials["vsphere_password"]
          end

          raise Veewee::Error, "Must define vsphere_server" if @vsphere_server.nil?
          raise Veewee::Error, "Must define vsphere_user" if @vsphere_user.nil?

          @vsphere_password ||= ask("#{@vsphere_user}@#{@vsphere_server} password: ") {|q| q.echo = false}
        end
      end #End Class
    end # End Module
  end # End Module
end # End Module
