require 'fileutils'
require 'optparse'
require 'ostruct'
require 'yaml'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'fission/action/shell_executor'
require 'fission/action/snapshot/creator'
require 'fission/action/snapshot/deleter'
require 'fission/action/snapshot/lister'
require 'fission/action/snapshot/reverter'
require 'fission/action/vm/cloner'
require 'fission/action/vm/deleter'
require 'fission/action/vm/lister'
require 'fission/action/vm/starter'
require 'fission/action/vm/stopper'
require 'fission/action/vm/suspender'
require 'fission/cli'
require 'fission/command'
require 'fission/command_helpers'
require 'fission/command_line_parser'
require 'fission/command/clone'
require 'fission/command/delete'
require 'fission/command/info'
require 'fission/command/snapshot_create'
require 'fission/command/snapshot_delete'
require 'fission/command/snapshot_list'
require 'fission/command/snapshot_revert'
require 'fission/command/start'
require 'fission/command/status'
require 'fission/command/stop'
require 'fission/command/suspend'
require 'fission/config'
require 'fission/core_ext/class'
require 'fission/core_ext/file'
require 'fission/core_ext/object'
require 'fission/fusion'
require 'fission/lease'
require 'fission/metadata'
require 'fission/response'
require 'fission/ui'
require 'fission/vm'
require 'fission/vm_configuration'
require 'fission/version'

module Fission
  extend self

  def config
    @config ||= Fission::Config.new
  end

end
