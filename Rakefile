require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'veewee'
Bundler::GemHelper.install_tasks

<<<<<<< HEAD
desc 'Default: run tests'
task :default => :test
=======
#Setup some base variables to use
veewee_dir = "."
lib_dir  = File.expand_path(File.join(veewee_dir, "lib"))
box_dir  = File.expand_path(File.join(veewee_dir, "boxes"))
vbox_dir = File.expand_path(File.join(veewee_dir, "tmp"))
tmp_dir  = File.expand_path(File.join(veewee_dir, "tmp"))
iso_dir  = File.expand_path(File.join(veewee_dir, "iso"))
definition_dir = File.expand_path(File.join(veewee_dir, "definitions"))
template_dir   = File.expand_path(File.join(veewee_dir, "templates"))
>>>>>>> master

require 'rake/testtask'
Bundler::GemHelper.install_tasks

<<<<<<< HEAD
desc 'Tests not requiring an real box'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

desc 'Tests requiring an real box'
Rake::TestTask.new do |t|
  t.name="realtest"
  t.libs << "test"
  t.libs << "."
  t.pattern = 'test/**/*_realtest.rb'
end

desc 'Verify ISO'
task :iso, [:box_name] do |t,args|
  require 'net/http'
  #if args.to_hash.size!=1
  #puts "needs one arguments: rake iso [\"yourname\"]"
  #exit
  #end
  Dir.glob("templates/*").each do |name|
    definition_name=File.basename(name)
    puts name
    definition=Veewee::Environment.new(:cwd => ".",:definition_dir => "templates").definitions[definition_name]
    next if definition.nil? || definition.iso_src.nil? || definition.iso_src==""
    begin
      url=definition.iso_src
      found=false
      response = nil
      while found==false
        uri=URI.parse(url)
        Net::HTTP.start(uri.host,uri.port) {|http|
          response = http.head(uri.path)
        }
        unless response['location'].nil?
          #puts "Redirecting to "+response['location']
          url=response['location']
        else
          found=true
        end
      end
      length=response['content-length']
      if length.to_i < 10000
        puts definition.iso_src
        p response['content-type']
        puts uri.host,uri.port, uri.path,response.code
      end
    rescue Exception => ex
      puts "Error"+ex.to_s+definition.iso_src
    end
  end
=======
#Load Veewee::Session libraries
Dir.glob(File.join(lib_dir, '**','*.rb')).each { |f| require f }

#Initialize
Veewee::Session.setenv({
  :veewee_dir => veewee_dir,
  :definition_dir => definition_dir,
  :template_dir => template_dir,
  :iso_dir => iso_dir,
  :box_dir => box_dir,
  :tmp_dir => tmp_dir
})

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
>>>>>>> master
end
