# Providers in Veewee

Initially veewee started as provider for virtualbox. From v0.3 Vmware fusion and KVM support are introduced.

## Virtualbox

To interact with virtualbox, veewee executes shell-commands through the 'VboxManage' command. The virtualbox gem library proved to be less stable.

To simulate the typing, veewee uses the 'VBoxManage controlvm 'myubuntu' keyboardputscancode <keycode>'.
Scancode are injected directly the keyboard buffer with this. And as this buffer is small, we can't type fast.
This is why you have the delay while veewee types the commands. Speeding it up, will make the keyboard buffer loose keystrokes.

## Vmware fusion

To interact with Vmware fusion, we leverage (a currently patched) version of [Fission gem](https://github.com/thbishop/fission). This takes care of the heavy lifting.

To interact with the screen , veewee enables VNC on the created vmware fusion machines and use the [Ruby-VNC gem](http://code.google.com/p/ruby-vnc/) to send the keystrokes. Here too , sending keystrokes too fast is a problem.

## KVM

To interact  with KVM veewee, uses [libvirt support](http://libvirt.org/ruby/) provided through [Fog gem](http://fog.io) libvirt support

To interact with the screen , veewee enables VNC on the created vmware fusion machines and use the [Ruby-VNC gem](http://code.google.com/p/ruby-vnc/) to send the keystrokes. Here too , sending keystrokes too fast is a problem.
