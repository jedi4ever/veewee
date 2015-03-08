# Veewee Installation

Before installing Veewee, please see the [Requirements](requirements.md) doc.
Currently supported versions of ruby: `1.9.3` to `2.2.1`
##### IMPORTANT: For best results, please us the latest version of Ruby.

## Install as a gem

The Veewee project is moving quickly and the Rubygem might be outdated. Therefore it may be wise to install Veewee from source.

    $ gem install veewee

The above command may fail when using OS X Mavericks and XCode 5.1 due to [Apple telling the install to fail when unknown flags are used](http://stackoverflow.com/questions/22313407/clang-error-unknown-argument-mno-fused-madd-python-package-installation-fa#22315129). To get around this, use:

	$ ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future gem install veewee
	

Projects that include the `veewee` gem can also benefit from utilizing Ruby version management (see below).


## Install from source

#### Installing Veewee without a Ruby version manager

Installing Veewee without a Ruby version manager is **NOT** recommended:

    $ cd <path_to_workspace>
    $ git clone https://github.com/jedi4ever/veewee.git
    $ cd veewee
    $ gem install bundler
    $ bundle install


#### Installing Veewee with RVM

With RVM already installed (see [Requirements](requirements.md)), ensure a ruby version that's supported by Veewee is available on your machine:

    $ rvm install ruby

Clone the veewee project from source:

    $ cd <path_to_workspace>
    $ git clone https://github.com/jedi4ever/veewee.git
    $ cd veewee

Set the local gemset and ruby version within the current directory:

    $ rvm use ruby@veewee --create

Run `bundle install` to install Gemfile dependencies for our local gemset:

    $ gem install bundler
    $ bundle install


#### Installing Veewee with rbenv

With rbenv already installed (see [Requirements](requirements.md)), ensure a ruby version that's supported by Veewee is available on your machine:

    $ rbenv install 2.2.1
    $ rbenv rehash

Clone the veewee project from source:

    $ cd <path_to_workspace>
    $ git clone https://github.com/jedi4ever/veewee.git
    $ cd veewee

Set the local ruby version within the current directory:

    $ rbenv local 2.2.1
    $ rbenv rehash

Run `bundle install` to install Gemfile dependencies for our selected ruby version:

    $ gem install bundler
    $ rbenv rehash
    $ bundle install
    $ rbenv rehash


#### Install from source on Windows

First, run `bundle install`.

Then to run `veewee`, use `bundle exec veewee` or make a powershell alias to remember for you:

    function Run-Veewee { bundle exec veewee }
    Set-Alias veewee Run-Veewee


#### Testing `kvm` while running from source

By default the `:kvm` gem group is *disabled* to prevent the installation of `ruby-libvirt` on systems
that don't need it. This is done by the file `.bundle/config`.

If you do need it, run `bundle install --without restrictions` (restrictions is a dummy name).
This will change the file `.bundle/config`, which is ignored by Git by default and must not be included in any commits. As this is a remembered option, you don't have to specify it every time.
If you want to switch to the default behavior run `bundle install --without kvm` to enable restrictions.


#### Running from source and using Ruby v1.8.7

By default the :windows gem group is *enabled* . This loads the `em-winrm` gem - which is incompatible with 
ruby-1.8.7 because it depends on the `gss-api` gem. To run from source you can execut `bundle install --without windows`

This will change the file `.bundle/config`, which is ignored by Git per default and must not be included in any commits. If you want to switch to the default behavior run `bundle install --without restrictions` to include it


## Up Next

[Veewee Command Options](commands.md) highlights various approaches for executing Veewee on the command line.
