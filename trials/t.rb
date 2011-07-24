require 'rubygems'
require 'pp'
require 'virtualbox'
vm=VirtualBox::VM.find("blub")
#vm.start
vm.state
#environment = VirtualBox::Lib.lib.environment

vm.with_open_environment do |environment|
	pp environment
	pp environment.console
	pp environment.console.keyboard
	pp environment.console.keyboard.methods
	environment.console.keyboard.put_scancode(20)
end
