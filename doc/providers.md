# Providers in Veewee

Initially veewee started as provider for Virtualbox.

From v0.3 VMware Fusion and KVM support are introduced.


## Virtualbox

To interact with virtualbox, veewee executes shell-commands through the 'VboxManage' command.
The `virtualbox` gem library proved to be less stable.

To simulate the typing, veewee uses the `VBoxManage` command:

    VBoxManage controlvm 'myubuntu' keyboardputscancode <keycode>

[Scancodes](http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html) are injected directly
from the keyboard buffer with this command.

And as this buffer is small, we can't type fast(er). This is why you have the delay while veewee types the commands.

Speeding it up, will make the keyboard buffer loose keystrokes.


## VMware Fusion

To interact with VMware Fusion, we leverage (a currently patched) version of [Fission gem](https://github.com/thbishop/fission).

This takes care of the heavy lifting.

To interact with the screen, veewee enables VNC on the created VMware Fusion machines
and use the [Ruby-VNC gem](http://code.google.com/p/ruby-vnc/) to send the keystrokes.

Sending keystrokes too fast is a problem as well.


## KVM

To interact with KVM veewee uses [libvirt support](http://libvirt.org/ruby/) provided through [Fog gem](http://fog.io).

To interact with the screen, veewee enables VNC on the created KVM machines
and uses the [Ruby-VNC gem](http://code.google.com/p/ruby-vnc/) to send the keystrokes.

Sending keystrokes too fast is a problem as well.