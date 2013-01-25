require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Vsphere
      class Provider < Veewee::Provider::Core::Provider

        attr_reader :host
        attr_reader :user
        attr_reader :password

        #include ::Veewee::Provider::Vsphere::ProviderCommand
        def initialize(name, options, env)
          super(name, options, env)
        end

        def check_requirements
          #Retrieve credentials for VMware Host
          # Credentials are used in this order
          #   Command Line
          #   ENV File
          @host = options['vsphere_host']
          @user = options['vsphere_user']
          @password = options['vsphere_password']

          cred_path = ENV["VEEWEE_VSPHERE_AUTHFILE"]
          unless cred_path.nil?
            env.logger.info "Reading credentials yamlfile #{cred_path}"
            credentials=YAML.load_file(cred_path)

            @host ||= credentials["host"]
            @user ||= credentials["user"]
            @password ||= credentials["password"]
          end

          raise Veewee::Error, "Must define host" if @host.nil?
          raise Veewee::Error, "Must define user" if @user.nil?

          @password ||= ask("#{@user}@#{@host} password: ") {|q| q.echo = false}
        end
      end #End Class
    end # End Module
  end # End Module
end # End Module
