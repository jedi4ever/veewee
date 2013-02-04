# Overview

Veewee is a tool to help you building a Virtual Machine from an ISO-file.


## Requirements

First, if you are not using [RVM](https://rvm.io/), it's recommended that you do so
as veewee will install in it's own [gemset](https://rvm.io/gemsets/basics/) which keeps veewee and it's dependancies
completely separate from your other Rubygems.

See https://rvm.io/gemsets/basics/ for details if you are new to this concept.

TODO ct 2013-02-4 Check if gemset is needed when using bundler

You can install it as follows:

    $ bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    $ source ~/.bash_profile

Now, install Ruby 1.9.2 using RVM:

    $ rvm install 1.9.2

Ok, now that we have RVM installed, you can now install Veewee.

TODO ct 2013-02-4 Merge this with [requirements.md](requirements.md)?


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

### Important:

_Note: testing `kvm` while running from source git repo_

By default the `:kvm` gem group is *disabled* to prevent the installation of `ruby-libvirt` on systems that don't need it. This is done by the file `.bundle/config`.

If you do need it, run `bundle install --without restrictions` (restrictions is a dummy name). This will change the file `.bundle/config`, which is ignored by Git per default and must not be included in any commits.

As this is a remembered option, you don't have to specify it every time. If you want to switch to the default behavior run `bundle install --without kvm` to enable restrictions.