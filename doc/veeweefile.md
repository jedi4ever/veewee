# Veeweefile

In cases were you'd like to set your own paths, feel free to create a `Veeweefile` in the project root:

    Veewee::Config.run do |config|
      
      # Initialize convenience vars
      cwd = File.dirname(__FILE__)
      env = config.veewee.env
      
      # These env settings will override default settings
      #env.cwd              = cwd
      #env.definition_dir   = File.join(cwd, 'definitions')
      #env.template_path    = [File.join(cwd, 'templates')]
      #env.iso_dir          = File.join(cwd, 'iso')
      #env.validation_dir   = File.join(cwd, 'validation')
      #env.tmp_dir          = "/tmp"

    end

An example where this may be useful is if you'd like create your own barebones project, include the `veewee` gem in that project's Gemfile, and then make sure your local `templates` directory is referenced rather than the templates found inside the veewee gem.

## Up Next

Either check out the [guide for Vagrant](vagrant.md) or review one of the various [guides for Providers](providers.md).
