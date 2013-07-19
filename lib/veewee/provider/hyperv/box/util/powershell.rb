module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def pscmd (scriptblock)
          unless scriptblock
            raise Veewee::Error, "Empty scriptblock passed to pscmd"
          end
          return "powershell -Command Invoke-Command -Computername #{definition.hyperv_server} -ScriptBlock {#{scriptblock}}"
        end

      end
    end
  end
end
