# VirtualBox VM Provider

To interact with [VirtualBox](http://www.virtualbox.org/), Veewee executes shell-commands through the 'VboxManage' command. The `virtualbox` gem library proved to be less stable.

To simulate the typing, Veewee uses the `VBoxManage` command:

    $ VBoxManage controlvm 'myubuntu' keyboardputscancode <keycode>

[Scancodes](http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html) are injected directly
from the keyboard buffer with this command. Because this buffer is small, Veewee can't type fast(er). This is why you'll notice a delay before Veewee types the commands. Speeding it up would make the keyboard buffer lose keystrokes.
