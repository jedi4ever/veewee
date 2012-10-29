module Veewee
  module Provider
    module Core
      module BoxCommand
        def create_floppy(floppy_filename)
          # Todo Check for java
          # Todo check output of commands
          # Todo allow for .erb templates

          # Check for floppy
          unless definition.floppy_files.nil?
            require 'tmpdir'
            temp_dir=Dir.mktmpdir
            definition.floppy_files.each do |filename|
              full_filename=full_filename=File.join(definition.path,filename)
              FileUtils.cp("#{full_filename}","#{temp_dir}")
            end
            javacode_dir=File.expand_path(File.join(__FILE__,'..','..','..','..','..','java'))
            floppy_file=File.join(definition.path,floppy_filename)
            if File.exists?(floppy_file)
              env.logger.info "Removing previous floppy file"
              FileUtils.rm(floppy_file)
            end
            command="java -jar #{javacode_dir}/dir2floppy.jar \"#{temp_dir}\" \"#{floppy_file}\""
            shell_exec("#{command}")
          end
        end

      end
    end
  end
end
