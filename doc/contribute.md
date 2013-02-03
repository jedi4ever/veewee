# Contribute or Improving a Veewee Template

## How to add a new OS/installation (needs some love)

I suggest the easiest way is to get an account on github and fork of the veewee repository

    $ git clone https://github.com/*your account*/veewee.git
    $ cd veewee
    $ gem install bundler
    $ bundle install

If you don't use rvm, be sure to execute vagrant through bundle exec

    $ alias veewee="bundle exec veewee"

Start of an existing one

    $ veewee vbox define 'mynewos' 'ubuntu...'

- Do changes in the currentdir/definitions/mynewos
- When it builds ok, move the definition/mynewos to a sensible directory under templates
- commit the changes (git commit -a)
- push the changes to github (git push)
- go to the github gui and issue a pull request for it

## If you have a setup working, share your 'definition' with me. That would be fun!
