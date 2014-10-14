require 'veewee/provider/core/helper/ssh'
require 'shellwords'
require 'pathname'

module Veewee
  module Provider
    module  Core
      module BoxCommand

        def ssh(command=nil,options={})

          raise Veewee::Error,"Box is not running" unless self.running?

          host_ip=self.ip_address

          if (options[:interactive]==true)
            unless host_ip.nil? || host_ip==""
              ssh_command="ssh #{ssh_commandline_options(options)} #{host_ip} #{Shellwords.escape(command) if command}"

              fg_exec(ssh_command,options)

            else
              ui.error("Can't ssh into '#{@name} as we couldn't figure out it's ip-address",:prefix => false)
            end
          else
            ssh_options={:user => definition.ssh_user,:password => definition.ssh_password, :port => definition.ssh_host_port}
            ssh_options[:keys] = ssh_key_to_a(definition.ssh_key) if definition.ssh_key
            ssh_execute(host_ip, command, ssh_options)
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
            "-o VerifyHostKeyDNS=no"
          ]
          if definition.ssh_key
            command_options << "-o IdentitiesOnly=yes"
            ssh_keys = ssh_key_to_a(definition.ssh_key)
            ssh_keys.each do |ssh_keys|
              # Filenames of SSH keys are relative to their definition
              ssh_key = Pathname.new(ssh_keys)
              ssh_key = File.join(definition.path, ssh_key) if ssh_key.relative?
              command_options << "-i #{ssh_key}"
            end
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
