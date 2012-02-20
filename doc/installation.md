This needs to be bulked out more, but for now, here is a basic guide to installing Veewee from source.

First, if you are not using RVM, it's recommended that you do so as veewee will install in it's own gemset which keeps veewee and it's dependancies completely separate from your other Ruby gems.

RVM is available here: http://beginrescueend.com/

You can install it as follows:

    $ bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    $ source ~/.bash_profile

Now, install Ruby 1.9.2 using RVM:

    $ rvm install 1.9.2

Ok, now that we have RVM installed, you can now install Veewee.

When you cd into the veewee directory, rvm should automatically read the .rvmrc file and prompt you to verify it - you can do so by pressing Y. This will then create a gemset for veewee.

    $ git clone https://github.com/jedi4ever/veewee.git
    $ cd veewee
    $ gem install bundler
    $ bundle install

