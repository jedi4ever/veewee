module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def build_info
          info=super
          #output=IO.popen("#{vmrun_cmd.shellescape}").readlines
          info << {:filename => ".vsphere_version",:content => vim.serviceContent.about.fullName }
        end

        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(options)
          #Arbitrarily sleep 15 seconds to ensure box is actually up before attempting the transfer
          ui.info "Waiting 120 seconds for ssh to be ready"
          sleep 120
          super(options)
        end

      end
    end
  end
end
