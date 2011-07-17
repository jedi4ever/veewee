
            def self.calculate_checksums(definition,boxname)

              #TODO: get rid of definitiondir and so one
              initial=definition.clone

              keys=[:postinstall_files,:sudo_cmd,:postinstall_timeout]
              keys.each do |key|
                initial.delete(key)
              end

              checksums=Array.new
              checksums << Digest::MD5.hexdigest(initial.to_s)

              postinstall_files=definition[:postinstall_files]
              unless postinstall_files.nil?
                for filename in postinstall_files
                  begin
                    full_filename=File.join(@definition_dir,boxname,filename)   

                    checksums << Digest::MD5.hexdigest(File.read(full_filename))
                  rescue
                    puts "Error reading postinstall file #{filename} - checksum"
                    exit
                  end
                end
              end

              return checksums

            end