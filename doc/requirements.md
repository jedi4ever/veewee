# Requirements

Veewee has a few requirements that must be met before you're able to use Veewee.


## Virtualization Providers

You'll need to install at least one of the supported VM providers (see [Providers](providers.md) doc for details). If you're not sure which provider to use, a common choice is [VirtualBox](http://www.virtualbox.org/) since it's free, portable, and supported by Vagrant.


## Development Libraries

Veewee is written in Ruby. In order to use Veewee you need Ruby installed as well as some header files
in order to compile native extensions that come as dependencies. If you already have experiences with Ruby this should be very straightforward. 


### For Linux

On Linux, you may need these packages in order to build native rubygems:

    libxslt1-dev
    libxml2-dev
    zlib1g-dev # or build-essential


### For Mac OS X

On Macs, either install `Xcode` or use [homebrew](http://mxcl.github.io/homebrew/) to install `apple-gcc42` or `build-essential`.


### For Windows

On Windows, you will need to install:

* Ruby devkit
* msysgit
* PowerShell (if on XP or Vista)
* PowerShell Community Extensions
* And you may need to add VirtualBox to your `PATH`, usually installed to `C:\Program Files\Oracle\VirtualBox`.


## Ruby Environment

It is highly recommended that you use either `rvm` or `rbenv` to manage your ruby versions.

Veewee currently supports Ruby version `1.9.3` to `2.2.1`
IMPORTANT : For best results, please use the latest version of Ruby.


### Option 1: RVM

[RVM](https://rvm.io/) is Veewee's prefered ruby version manager. 

RVM will allow Veewee to install its own [gemset](https://rvm.io/gemsets/basics/) and configure its own ruby version - which keeps Veewee and its dependancies completely separate from your other projects. Please see https://rvm.io/gemsets/basics/ for details if you are new to the concept of 'gemsets'.


##### Installing RVM

Please see the [RVM install documentation](https://rvm.io/rvm/install) for up-to-date installation instructions.


### Option 2: rbenv

[rbenv](https://github.com/sstephenson/rbenv) is another popular ruby version manager that you can use as an alternative to RVM.


##### Installing rbenv

Please see the [rbenv README]( https://github.com/sstephenson/rbenv/#installation) for up-to-date installation instructions.


## Up Next

Ok, now that we have cover all the requirements, you can move on with [installing Veewee](installation.md).
