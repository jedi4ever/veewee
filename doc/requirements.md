# Requirements

Veewee is written in Ruby. In order to use it you need Ruby installed and some header files
in order to compile native extensions that come as dependencies with veewee.

If you already have experiences with Ruby this should be very straightforward.

## Development Libraries

In order to build native rubygems you may need these packages:

    libxslt1-dev
    libxml2-dev
    zlib1g-dev

## Ruby Environment

First, if you are not using [RVM](https://rvm.io/), it's recommended that you do so
as veewee will install in it's own [gemset](https://rvm.io/gemsets/basics/) which keeps veewee and it's dependancies
completely separate from your other Rubygems.

See https://rvm.io/gemsets/basics/ for details if you are new to the concept of 'gemsets'.

TODO ct 2013-02-4 Check if gemset is needed when using bundler

You can install RVM as follows:

    $ bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    $ source ~/.bash_profile

Now, install Ruby 1.9.2 using RVM:

    $ rvm install 1.9.2

Ok, now that we have RVM installed, you can now [install Veewee](installation.md).
