require 'rubygems'
require 'bundler'
require 'bundler/setup'
Bundler::GemHelper.install_tasks

desc 'Default: run tests'
task :default => :test

require 'rake/testtask'
Bundler::GemHelper.install_tasks


Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

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

desc 'Export box'
task :export, [:boxname] do |t,args|
  if args.to_hash.size!=1
    puts "needs one arguments: rake export['boxname']"
    exit
  end
    Veewee::Session.export_box(args.boxname)
end

desc 'Remove box'
task :remove_box, [:boxname] do |t,args|
    Veewee::Session.remove_box(args.boxname)
end

desc 'List ostypes available'
task :list_ostypes do |t,args|
    Veewee::Session.list_ostypes
end

desc 'Clean all unfinished builds'
task :clean do 
    Veewee::Session.clean
end
