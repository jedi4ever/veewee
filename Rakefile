ENV['GEM_PATH']=File.dirname(__FILE__)
ENV['GEM_HOME']=File.dirname(__FILE__)

def check_environment
  begin 
    require 'vagrant'
  rescue LoadError
    puts "you need to install depedencies:"
    puts "gem install vagrant"
    exit
  end
  
  begin 
    require 'net/ssh'
    require 'virtualbox'
    require 'webrick'
    require 'popen4'
  rescue LoadError
    puts "hmm you had vagrant installed but are missing the net-ssh or virtualbox gem"
    puts "gem install virtualbox net-ssh POpen4"
    exit
  end
end

#See if all gems and so are installed
check_environment

#Setup some base variables to use
veewee_dir= File.dirname(__FILE__)
definition_dir= File.expand_path(File.join(veewee_dir, "definitions"))
lib_dir= File.expand_path(File.join(veewee_dir, "lib"))
template_dir=File.expand_path(File.join(veewee_dir, "templates"))
vbox_dir=File.expand_path(File.join(veewee_dir, "tmp"))
iso_dir=File.expand_path(File.join(veewee_dir, "iso"))
ENV['VBOX_USER_HOME']=vbox_dir

#Load Veewee::Session libraries
Dir.glob(File.join(lib_dir, '**','*.rb')).each {|f| 
  require f  }

#Initialize
Veewee::Session.setenv({:veewee_dir => veewee_dir, :definition_dir => definition_dir, :template_dir => template_dir, :iso_dir => iso_dir})

desc 'Default: list templates'
task :default => [:templates]

desc 'List templates'
task :templates do
    Veewee::Session.list_templates
end

desc 'Define box'
task :define, [:boxname,:template_name] do |t,args|
    if args.to_hash.size!=2
      puts "needs two arguments: rake define['boxname','template_name']"
      exit
    end
    Veewee::Session.define(args.boxname,args.template_name)
end

desc 'Undefine box'
task :undefine, [:boxname] do |t,args|
    if args.to_hash.size!=1
      puts "needs one arguments: rake undefine[\"yourname\"]"
      exit
    end
    Veewee::Session.undefine(args.boxname)
end

desc 'List Definitions'
task :definitions do 
    Veewee::Session.list_definitions
end

desc 'Build box'
task :build, [:boxname] do |t,args|
    if args.to_hash.size!=1
      puts "needs one arguments: rake build['boxname']"
      exit
    end
    Veewee::Session.build(args.boxname)
end

desc 'List boxes'
task :boxes do
    Veewee::Session.list_boxes
end

desc 'Remove box'
task :remove_box, [:boxname] do |t,args|
    Veewee::Session.remove_box(args.boxname)
end

desc 'Clean all unfinished builds'
task :clean do 
    Veewee::Session.clean
end