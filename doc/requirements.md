# Requirements

Veewee is written in Ruby. In order to use it you need Ruby installed and some header files
in order to compile native extensions that come as dependencies with veewee.

If you already have experiences with Ruby this should be very straightforward.

## Development Libraries

In order to build native rubygems you may need these packages:

    libxslt1-dev
    libxml2-dev
    zlib1g-dev

On windows, you will need to install:

- Ruby devkit
- msysgit
- And you may need to add VirtualBox to your `PATH`, usually installed to `C:\Program Files\Oracle\VirtualBox`.


## Ruby Environment

### Option 1: RVM

If you are not using [RVM](https://rvm.io/), it's recommended that you do so
as veewee will install in it's own [gemset](https://rvm.io/gemsets/basics/) which keeps veewee and it's dependancies
completely separate from your other Rubygems.

See https://rvm.io/gemsets/basics/ for details if you are new to the concept of 'gemsets'.

TODO ct 2013-02-4 Check if gemset is needed when using bundler

You can install RVM as follows:

    $ bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    $ source ~/.bash_profile

Now, install Ruby 1.9.2 using RVM:

    $ rvm install 1.9.2
    
### Option 2: rbenv

As an alternative to RVM, you can opt to use [rbenv](https://github.com/sstephenson/rbenv/) with 
[ruby-build](https://github.com/sstephenson/ruby-build):

    $ rbenv install 1.9.2-p320
    $ rbenv rehash
    
## Up Next

Ok, now that we have the appropriate ruby environment installed, you can move on with [installing Veewee](installation.md).
