require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand


        def issh(command=nil,options={})

          raise Veewee::Error,"Box is not running" unless self.running?
          # Command line options
          extended_command="#{command}"
          host_ip=self.ip_address

          unless host_ip.nil? || host_ip==""
            ssh_command="ssh #{ssh_commandline_options(options)} #{host_ip} \"#{extended_command}\""

            fg_exec(ssh_command,options)

          else
            env.ui.error "Can't ssh into '#{@name} as we couldn't figure out it's ip-address"
          end
        end

        private
        def ssh_commandline_options(options)

          command_options = [
            #"-q", #Suppress warning messages
            #            "-T", #Pseudo-terminal will not be allocated because stdin is not a terminal.
            "-p #{ssh_options[:port]}",
            "-o UserKnownHostsFile=/dev/null",
            "-t -o StrictHostKeyChecking=no",
            "-o IdentitiesOnly=yes",
            "-o VerifyHostKeyDNS=no"
          ]
          if !(definition.ssh_key.nil? ||  definition.ssh_key.length!="")
            command_options << "-i #{definition.ssh_key}"
          end
          commandline_options="#{command_options.join(" ")} ".strip

          user_option=definition.ssh_user.nil? ? "" : "-l #{definition.ssh_user}"

          return "#{commandline_options} #{user_option}"
        end


        def fg_exec(ssh_command,options)
          # Some hackery going on here. On Mac OS X Leopard (10.5), exec fails
          # (GH-51). As a workaround, we fork and wait. On all other platforms,
          # we simply exec.
          pid = nil
          pid = fork if Platform.leopard? || Platform.tiger?

          env.logger.info "Executing internal ssh command"
          env.logger.info ssh_command
          Kernel.exec ssh_command if pid.nil?
          Process.wait(pid) if pid
        end

        # Shameless copy of vagrant
        class Platform
          class << self
            def tiger?
              platform.include?("darwin8")
            end

            def leopard?
              platform.include?("darwin9")
            end

            [:darwin, :bsd, :linux].each do |type|
              define_method("#{type}?") do
                platform.include?(type.to_s)
              end
            end

            def platform
              RbConfig::CONFIG["host_os"].downcase
            end
          end
        end

      end # Module
    end # Module
  end # Module
end # Module

