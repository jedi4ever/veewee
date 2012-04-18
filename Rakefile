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
  t.libs << "."
  t.pattern = 'test/**/*_realtest.rb'
end

desc 'Verify ISO'
task :iso, [:template_name] do |t,args|
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
end

desc 'Autobuilds all templates and runs validation.'
task :autotest, [:pattern] do |t,args|

  # We overrule all timeouts for tcp and ssh
  #ENV['VEEWEE_TIMEOUT']='600'

  ve=Veewee::Environment.new()
  ve.templates.each do |name,template|

    # If pattern was given, only take the ones that match the pattern
    unless args[:pattern].nil?
      next unless name.match(args[:pattern])
    end

    begin
      ve.definitions.define("auto",name, { 'force' => true})
      vd=ve.definitions["auto"]
      box=ve.providers["virtualbox"].get_box("auto")
      puts "AUTO: Building #{name}"
      box.build({"auto" => true,"force" => true, 'nogui' => true })
      puts "AUTO: Validating #{name}"
      box.validate_vagrant
      puts "AUTO: Success #{name}"
      box.destroy
    rescue Exception => ex
      puts "AUTO: Template #{name} failed - #{ex}"
      if box.running?
        begin
          screenshot="screenshot-auto-#{name}.png"
          puts "AUTO: Taking snapshot #{screenshot}"
          box.screenshot(screenshot)
        rescue Veewee::Error => ex
          puts "AUTO: Error taking screenshot"
        end
      end
    end

  end
end
