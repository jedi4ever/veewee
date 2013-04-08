# Overview

Veewee is a tool to help you building a Virtual Machine from an ISO-file.


## Requirements

Please see [requirements.md](requirements.md) for detailed instructions.


## Install

These instructions need to be bulked out more, but for now, here is a basic guide to installing Veewee.

The Veewee project is moving quickly and the Rubygem might be outdated. We recommend installing Veewee from source.

__as a gem__

    $ gem install veewee

__from source__

When you cd into the veewee directory, rvm should automatically read the `.rvmrc` file
and prompt you to verify it - you can do so by pressing `Y`.

This will then create a [gemset](https://rvm.io/gemsets/basics/) for veewee.

    $ git clone https://github.com/jedi4ever/veewee.git
    $ cd veewee
    $ gem install bundler
    $ bundle install

Now start [building baseboxes](running.md) or learn more about [veewee's internals](definition.md)!

__from source on windows__

1. Run `bundle install`

2. To run `veewee`, use `bundle exec veewee` or make a powershell alias to remember for you:

    function Run-Veewee { bundle exec veewee }
    Set-Alias veewee Run-Veewee


### Important Note on testing `kvm` while running from source git repo_

By default the `:kvm` gem group is *disabled* to prevent the installation of `ruby-libvirt` on systems
that don't need it. This is done by the file `.bundle/config`.

If you do need it, run `bundle install --without restrictions` (restrictions is a dummy name).
This will change the file `.bundle/config`, which is ignored by Git per default and must not be included in any commits.

As this is a remembered option, you don't have to specify it every time.
If you want to switch to the default behavior run `bundle install --without kvm` to enable restrictions.

### Running from source git repo and using ruby 1.8.7

By default the :windows gem group is *enabled* . This loads the em-winrm gem which is incompatible with ruby-1.8.7 as it depends on the gss-api gem. To run from source you can do a `bundle install --without windows`

This will change the file `.bundle/config`, which is ignored by Git per default and must not be included in any commits.
If you want to switch to the default behavior run `bundle install --without restrictions` to include it

