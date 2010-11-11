require 'rubygems'
require 'pp'
require 'virtualbox'
vm=VirtualBox::VM.find("blub")
#vm.start
vm.state
#session = VirtualBox::Lib.lib.session

vm.with_open_session do |session|
	pp session
	pp session.console
	pp session.console.keyboard
	pp session.console.keyboard.methods
	session.console.keyboard.put_scancode(20)
end
