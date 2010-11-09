base_dir= File.dirname(__FILE__)
box_definition_dir= File.dirname(__FILE__)+"/"+"definitions"

desc 'Default: list option'
task :default => [:test]

desc 'Build box'
task :build, [:box] do |t,args|
    box=args.box
    if File.directory?("#{box_definition_dir}/#{box}")
              if run_box.length!=0
                    puts "Executing #{run_box}"
                    require("#{run_box}")
              end
      end

end

desc 'Test box'
task :test, [:box] do |t,args|
	system("puppet apply -v --debug --modulepath=#{base_dir}/modules recipe/site.pp")
end

desc 'List Boxes'
task :list do

  subdirs=Dir.glob("#{box_definition_dir}/*")
  subdirs.each do |sub|
          if File.directory?("#{sub}")
                  run_box=Dir.glob("#{sub}/run.rb")
                  clean_box=Dir.glob("#{sub}/clean.rb")
                  if run_box.length!=0
                          name=sub.sub(/#{box_dir}\//,'')
                          puts "rake run['#{name}']"
                  end
                  if clean_box.length!=0
                          name=sub.sub(/#{box_dir}\//,'')
                          puts "rake clean['#{name}']"
                  end
          end
  end

end

