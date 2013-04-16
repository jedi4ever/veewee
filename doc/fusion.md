## VMware Fusion VM Provider

To interact with [VMware (Fusion)](http://www.vmware.com/products/fusion/), we leverage (a currently patched) version of [Fission gem](https://github.com/thbishop/fission). This gem takes care of the heavy lifting.

To interact with the screen, Veewee enables VNC on the created VMware Fusion machines
and uses the [Ruby-VNC gem](http://code.google.com/p/ruby-vnc/) to send the keystrokes. Sending keystrokes too fast is a problem for this setup as well.
