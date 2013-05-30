require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'veewee'
Bundler::GemHelper.install_tasks

desc 'Default: run tests'
task :default => :test

require 'rake/testtask'

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
task :iso, [:template_name] do |t, args|
  require 'net/http'
  #if args.to_hash.size!=1
  #puts "needs one arguments: rake iso [\"yourname\"]"
  #exit
  #end
  Dir.glob("templates/*").each do |name|
    definition_name = File.basename(name)

    # If pattern was given, only take the ones that match the pattern
    unless args[:template_name].nil?
      next unless definition_name == args[:template_name]
    end

    puts name
    definition = Veewee::Environment.new(:cwd => ".", :definition_dir => "templates").definitions[definition_name]
    next if definition.nil? || definition.iso_src.nil? || definition.iso_src == ""
    begin
      url = definition.iso_src
      found = false
      response = nil
      while found == false
        uri = URI.parse(url)
        if uri.is_a?(URI::HTTP)
          Net::HTTP.start(uri.host, uri.port) { |http|
            response = http.head(uri.path)
          }
          unless response['location'].nil?
            #puts "Redirecting to "+response['location']
            url = response['location']
          else
            length = response['content-length']
            found = true
          end
        elsif uri.is_a?(URI::FTP)
          require 'net/ftp'
          ftp = Net::FTP.new(uri.host)
          ftp.login
          begin
            length = ftp.size(uri.path)
            found = true
          rescue Net::FTPReplyError => e
            reply = e.message
            err_code = reply[0, 3].to_i
            unless err_code == 500 || err_code == 502
              # other problem, raise
              raise "Got ftp site but doesn't support size subcommand"
            end
            # fallback solution
          end

        end
      end
      if length.to_i < 10000
        puts definition.iso_src
        puts "Incorrect length #{length.to_i}"
        puts uri.host, uri.port, uri.path, response.code
      end
    rescue Exception => ex
      puts "Error" + ex.to_s + definition.iso_src
    end
  end
end

desc 'Builds a template and runs validation.'
task :autotest, [:template_name] do |t, args|

  # Disable color if the proper argument was passed
  shell = ARGV.include?("--no-color") ? Thor::Shell::Basic.new : Thor::Base.shell.new

  # We overrule all timeouts for tcp and ssh
  #ENV['VEEWEE_TIMEOUT']='600'

  ve = Veewee::Environment.new
  ve.ui = ::Veewee::UI::Shell.new(ve, shell)
  ve.templates.each do |name, template|

    definition_name = File.basename(name)
    # If pattern was given, only take the ones that match the pattern
    unless args[:template_name].nil?
      next unless definition_name == args[:template_name]
    end

    begin
      puts "Using template name - #{name}"
      ve.definitions.define("auto", name, { 'force' => true })
      vd = ve.definitions["auto"]
      box = ve.providers["virtualbox"].get_box("auto")
      if box.running?
        puts "AUTO: Invalid state - box '#{box.definition.iso_file}' running from previous invocation. Manually destroy box to continue with tests."
        exit -1
      end
      puts "AUTO: Building #{name}"
      box.build({ "auto" => true, "force" => true, 'nogui' => true })
      puts "AUTO: Validating #{name}"
      box.validate_vagrant({'tags' => ['virtualbox']})
      puts "AUTO: Success #{name}"
      box.destroy
    rescue Exception => ex
      puts "AUTO: Template #{name} failed - #{ex}"
      if box.running?
        begin
          screenshot = "screenshot-auto-#{name}.png"
          puts "AUTO: Taking snapshot #{screenshot}"
          box.screenshot(screenshot)
        rescue Veewee::Error => ex
          puts "AUTO: Error taking screenshot"
        end
      end
      exit -1
    end

  end
end
