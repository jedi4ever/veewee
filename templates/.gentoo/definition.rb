# this file contains variables to customize your build.
# you should also have a look at settings.sh (should be move here when templates are working)

require 'net/http'
require File.dirname(__FILE__) + "/common_definition.rb"
require File.dirname(__FILE__) + "/architecture_definition.rb"
require File.dirname(__FILE__) + "/gentoo_definition.rb"

# install ruby form source ? (or package)
ruby_from_source = false

session =
  GENTOO_SESSION#.merge(
                #      )

position_of_reboot = Hash[session[:postinstall_files].map.with_index.to_a]['reboot.sh'] + 1

if ruby_from_source
  session[:postinstall_files].insert(position_of_reboot,'ruby_source.sh')
else
  session[:postinstall_files].insert(position_of_reboot,'ruby_portage.sh')
end

Veewee::Session.declare session
