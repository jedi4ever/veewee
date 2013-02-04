module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        attr_reader :vnc_port
        attr_reader :vnc_host

        def enable_vnc 
          vm = raw
          @vnc_host = reachable_ip raw.collect('runtime.host')[0]
          extraConfig, = raw.collect('config.extraConfig')
          already_enabled = extraConfig.find { |x| x.key == 'RemoteDisplay.vnc.enabled' && x.value.downcase == 'true' }
          if already_enabled
            puts "VNC already enabled"
            real_vnc_port = extraConfig.find { |x| x.key == 'RemoteDisplay.vnc.port' }.value
            #Modify the port to work around the way Veewee's VNC class is implemented
            @vnc_port = real_vnc_port - 5900
          else
            real_vnc_port = unused_vnc_port vnc_host
            #Modify the port to work around the way Veewee's VNC class is implemented
            @vnc_port = real_vnc_port - 5900
            vm.ReconfigVM_Task(:spec => {
              :extraConfig => [
                { :key => 'RemoteDisplay.vnc.enabled', :value => 'true' },
                { :key => 'RemoteDisplay.vnc.port', :value => real_vnc_port.to_s }
              ]
            }).wait_for_completion
          end
        end

        def reachable_ip host
          ips = host.collect('config.network.vnic')[0].map { |x| x.spec.ip.ipAddress }
          ips.find do |x|
            begin
              Timeout.timeout(1) { TCPSocket.new(x, 443).close; true }
            rescue
                false
            end
          end or err("could not find IP for server #{host.name}")
        end

        def unused_vnc_port ip
          10.times do
            port = 5901 + rand(64)
            unused = (TCPSocket.connect(ip, port).close rescue true)
            return port if unused
          end
          err "no unused port found"
        end

        def close_vnc 
          vm = raw
          vm.ReconfigVM_Task(:spec => {
            :extraConfig => [
              { :key => 'RemoteDisplay.vnc.enabled', :value => 'false' },
              { :key => 'RemoteDisplay.vnc.password', :value => '' },
              { :key => 'RemoteDisplay.vnc.port', :value => '' }
            ]
          }).wait_for_completion
        end

        def vnc_enabled?
          extraConfig, = raw.collect('config.extraConfig')
          return extraConfig.find { |x| x.key == 'RemoteDisplay.vnc.enabled' && x.value.downcase == 'true' }
        end

      end
    end
  end
end
