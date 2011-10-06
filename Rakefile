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
end
