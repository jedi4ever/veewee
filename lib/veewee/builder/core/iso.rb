module Veewee
  module Builder
    module Core
      
      require 'open-uri'
      require 'progressbar'
      require 'highline/import'
      require 'digest/md5'
      
      #TODO move to veewee definition?
      
      def download_progress(url,localfile)
        pbar = nil
        URI.parse(url).open(
        :content_length_proc => lambda {|t|
          if t && 0 < t
            pbar = ProgressBar.new("Fetching file", t)
            pbar.file_transfer_mode
          end
          },
          :progress_proc => lambda {|s|
            pbar.set s if pbar
            }) { |src|
              open("#{localfile}","wb") { |dst|
                dst.write(src.read)
              }
            }

          end

          def verify_iso(filename,autodownload = false)
            if File.exists?(File.join(@environment.iso_dir,filename))
              puts 
              puts "Verifying the isofile #{filename} is ok."
            else

              full_path=File.join(@environment.iso_dir,filename)
              path1=Pathname.new(full_path)
              path2=Pathname.new(Dir.pwd)
              rel_path=path1.relative_path_from(path2).to_s

              puts
              puts "We did not find an isofile in <currentdir>/iso. \n\nThe definition provided the following download information:"
              unless "#{@definition.iso_src}"==""
                puts "- Download url: #{@definition.iso_src}"
              end
              puts "- Md5 Checksum: #{@definition.iso_md5}"
              puts "#{@definition.iso_download_instructions}"
              puts

              if @definition.iso_src == ""
                puts "Please follow the instructions above:"
                puts "- to get the ISO"
                puts" - put it in <currentdir>/iso"
                puts "- then re-run the command"
                puts
                exit
              else

                question=ask("Download? (Yes/No)") {|q| q.default="No"}
                if question.downcase == "yes"
                  if !File.exists?(@environment.iso_dir)
                    puts "Creating an iso directory"
                    FileUtils.mkdir(@environment.iso_dir)
                  end

                  download_progress(@definition.iso_src,full_path)
                else
                  puts "You have choosen for manual download: "
                  puts "curl -C - -L '#{@definition.iso_src}' -o '#{rel_path}'"
                  puts "md5 '#{rel_path}' "
                  puts 
                  exit
                end

              end
            end

          end
        end #Module
      end #Module
    end #Module
