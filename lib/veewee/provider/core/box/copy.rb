module Veewee
  module Provider
    module  Core
      module BoxCommand

        def copy_to_box(localfile,remotefile,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          if
            definition.winrm_user && definition.winrm_password # prefer winrm
          then
            self.wincp(localfile,remotefile,options)
          elsif
            definition.os_type_id =~ /^Windows/
          then
            raise "Trying to transfer #{localfile} to windows machine without 'winrm_user' and 'winrm_password' set in definition."
          else
            self.scp(localfile,remotefile,options)
          end
        end
      end # Module
    end # Module
  end # Module
end # Module
