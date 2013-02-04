# Contribute or Improving a Veewee Templates

If you have a setup working, share your 'definition' with me. That would be fun!

## How to add a new OS/installation

I suggest the easiest way is to get an account on [Github](https://github.com).

I assume that you have a working ruby environment as described in `installation.md`.

Then fork [the veewee repository](https://github.com/jedi4ever/veewee) to your account and clone it to your computer:

    $ git clone https://github.com/*your account*/veewee.git
    $ cd veewee
    $ gem install bundler
    $ bundle install

If you don't use [rvm](https://rvm.io/), be sure to execute veewee through `bundle exec`:

    $ alias veewee="bundle exec veewee"

Start your new definition on base of an existing one by executing:

    $ veewee vbox define 'mynewos' '<your_os_of_choice>'

Now follow these best practices:

- Apply your changes in `./definitions/mynewos`
- Build it with `veewee vbox build 'mynewos'`
- Validate with `veewee vbox validate 'mynewos'`
- When it builds OK and all tests are green, move `definition/mynewos` to a sensible directory under templates<br>
  Hint: Follow the naming schema of existing boxes
- Commit the changes: `git commit -a`
- Push the changes to github: `git push`
- Go to github and issue a pull request: `https://github.com/*your account*/veewee/pull/new/master`

TODO ct 2013-02-4 Bonuspoints for feature-branches and adding tests to verify new post installs?