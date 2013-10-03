# Contribute to Veewee

If you are looking to improve Veewee in some manner, you've come to the right place.


## TODOs

A running [TODO](doc/TODO.md) list is available for ideas on future improvements.


## Steps to Contribute

### Getting started

In order to contribute anything, you'll want to follow these steps first:

* Get an account on [Github](https://github.com)
* Then fork the [veewee repository](https://github.com/jedi4ever/veewee) to your own Github account
* If you haven't already, familiarize yourself with the [Requirements](doc/requirements.md) and [Installation](doc/installation.md) docs
* Clone the veewee **fork** to your machine:

    ~~~ sh
    $ cd <path_to_workspace>
    $ git clone https://github.com/<your github account>/veewee.git
    $ cd veewee
    ~~~

* Check out a new branch to make your changes on: `git checkout -b <your_new_patch>`


### For adding a new Template

If you have a new and amazing Veewee definition, share your 'template'. That would be fun!

* Before saving changes to a 'template', first try your changes in `definitions/mynewos/`
* Build the box and run the **validation** tests
* When the box builds OK and all tests are green, move `definition/mynewos/` to a sensible directory under the `templates/` directory. **Hint:** Follow the same naming schema of existing boxes (explained in the [Veewee Basics](doc/basics.md) doc)


### For adding new Features

* Run any existing tests that are related to your patch
* For bonus points add tests to validate your changes


### To submit your Contribution

* Please commit with descriptive messages
* Submit a pull request on Github from the __your_new_patch__ branch on __your fork__ to the __master__ branch on __jedi4ever/veewee__
* One of the editors will review the change, and either merge it or provide some feedback. Community review is also encouraged.

