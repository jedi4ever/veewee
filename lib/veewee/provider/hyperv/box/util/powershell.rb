module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def powershell_exec(scriptblock,options = {:remote => true})

          raise Veewee::Error,"Empty scriptblock passed to powershell_exec" unless scriptblock

          defaults = {:mute => true,:status => 0,:stderr => "&1"}
          options = defaults.merge(options)

          if options[:remote] then
            return shell_exec("powershell -Command Invoke-Command -Computername #{definition.hyperv_host} -ScriptBlock {#{scriptblock}}",options)
          else
            return shell_exec("powershell -Command -ScriptBlock {#{scriptblock}}",options)
          end
        end

      end
    end
  end
end
