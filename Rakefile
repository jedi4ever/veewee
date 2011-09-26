require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'veewee'
Bundler::GemHelper.install_tasks

desc 'Default: run tests'
task :default => :test

require 'rake/testtask'
Bundler::GemHelper.install_tasks

desc 'Tests not requiring an real box'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

desc 'Tests requiring an real box'
Rake::TestTask.new do |t|
  t.name="realtest"
  t.libs << "test"
  t.pattern = 'test/**/*_realtest.rb'
end

desc 'Tests requiring an real box'
Rake::TestTask.new do |t|
  t.name="realtest"
  t.libs << "test"
  t.pattern = 'test/**/*_realtest.rb'
end

desc 'Verify ISO'
task :iso, [:box_name] do |t,args|
    #if args.to_hash.size!=1
      #puts "needs one arguments: rake iso [\"yourname\"]"
      #exit
    #end
    Dir.glob("templates/*").each do |name|
      definition_name=File.basename(name)
      definition=Veewee::Environment.new(:cwd => ".",:definition_dir => "templates",:definition_path => "templates").get_definition(definition_name)
      puts definition.iso_src
    end
end
