module Veewee
  module Provider
    module  Core
      module BoxCommand

        def copy_to_box(localfile,remotefile,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          if definition.winrm_user && definition.winrm_password # prefer winrm 
            self.wincp(localfile,remotefile,options)
          else
            self.scp(localfile,remotefile,options)
          end
        end
      end # Module
    end # Module
  end # Module
end # Module
