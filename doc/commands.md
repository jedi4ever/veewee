# Veewee Command Options

You can choose from a few different command line options when executing Veewee.

## Veewee with `bundle exec`

Unless you've created an alias for `veewee`, always include the `bundle exec` prefix like this:

    $ bundle exec veewee


## Veewee without `bundle exec`

For convenience, it's handy to create an alias for the `veewee` command so we don't have to type `bundle exec` any longer. 

Add the alias `alias veewee='bundle exec veewee'` to your shell's default startup file (e.g. ~/.bash_profile):

    echo "alias veewee='bundle exec veewee'" >> ~/.bash_profile

**For Ubuntu:** Modify your ~/.profile instead of ~/.bash_profile.
<br>**For Zsh:** Modify your ~/.zshrc file instead of ~/.bash_profile.

After adding the alias described above you'll be able to use the shorthand `veewee` command:

    $ veewee
    

## Veewee as a Vagrant Plugin

You can also use Veewee as a [Vagrant plugin](http://docs.vagrantup.com/v2/plugins/index.html).

As a plugin, Veewee introduces the subcommand `basebox` on top of the `vagrant` command:

    $ vagrant basebox
    Usage: vagrant basebox <command> [<args>]

This allows you to use the `vagrant` command style, which may feel more natural if you're already used to working with Vagrant. Please see Veewee's [Vagrant](vagrant.md) doc for more details.


## Up Next

[Veewee Basics](basics.md) covers creating standard-issue boxes.
