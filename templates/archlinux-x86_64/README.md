# Arch Linux


## Tip

Since this is a "net" install and all packages are downloaded, you can
speed up the download of the base packages by getting [Pacman][] to use
a suitable [mirror][].

For example, I modified the definition to make Pacman use Australian and
New Zealand mirrors.

    @@ -27,6 +27,7 @@
       'passwd<Enter>',
       "#{root_password}<Enter>",
       "#{root_password}<Enter>",
    +    "echo 'Server = http://mirror.xnet.co.nz/pub/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist<Enter>",
       'systemctl start sshd.service<Enter><Wait>',
     ],
     :ssh_login_timeout => '10000',
    @@ -58,6 +59,6 @@
     ],
     :postinstall_timeout => '10000',
     :params => {
    -    #:PACMAN_REFLECTOR_ARGS => '--verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist',
    +    :PACMAN_REFLECTOR_ARGS => '--verbose -c "New Zealand" -c Australia -n 5 --sort rate --save /etc/pacman.d/mirrorlist',
     }
    })

You can obtain a suitable mirrorlist for yourself using the [Pacman
Mirrorlist Generator][]. The list of countries with mirrors is on that
page too.

Once the base system is installed, the template uses [Reflector][] to
set up Pacman's mirrorlist for the remaining packages. By default, the
arguments passed to Reflector favour up-to-date mirrors sorted by their
download rate. As shown above, you may customize the arguments to your
liking.


## Note

* Reflector is uninstalled by the template following the mirrorlist
  generation
* The template currently only supports VirtualBox provider


[Pacman]: https://wiki.archlinux.org/index.php/Pacman
[mirror]: https://wiki.archlinux.org/index.php/Mirrors
[Pacman Mirrorlist Generator]: https://www.archlinux.org/mirrorlist/
[Reflector]: https://wiki.archlinux.org/index.php/Reflector
