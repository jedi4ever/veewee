# Alpine Linux

Minimal build of the 'Virtual'-Image.

## Note

* The template currently only supports the VirtualBox provider
* shutdown for vagrant is provided under /usr/local/bin
* ``who`` and alike do not work because of [musl][] not providing utmp
* if you want alpine-sdk with aports include ``aports.sh in`` in ``definition.rb``

[musl]: http://wiki.musl-libc.org/wiki/FAQ#Q:_why_is_the_utmp.2Fwtmp_functionality_only_implemented_as_stubs_.3F
# Alpine Linux
