module Veewee
  module Builder
    module Core
      module BuilderCommand

        require 'open-uri'
        require 'progressbar'
        require 'highline/import'
        require 'digest/md5'

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

        # Compute hash code
        def hashsum(filename)
          checksum=Digest::MD5.new
          buflen=1024
          open(filename, "r") do |io|
            counter = 0
            while (!io.eof)
              readBuf = io.readpartial(buflen)
              env.ui.info '.' if ((counter+=1) % 20000 == 0)
              checksum.update(readBuf)
            end
          end
          return checksum.hexdigest
        end


        def verify_iso(definition,autodownload = false)
          filename=definition.iso_file
          full_path=File.join(env.config.veewee.iso_dir,filename)

          if File.exists?(full_path)
            env.ui.info ""
            env.ui.info "The isofile #{filename} already exists."
          else

            path1=Pathname.new(full_path)
            path2=Pathname.new(Dir.pwd)
            rel_path=path1.relative_path_from(path2).to_s

            env.ui.info ""
            env.ui.info "We did not find an isofile in <currentdir>/iso. \n\nThe definition provided the following download information:"
            unless "#{definition.iso_src}"==""
              env.ui.info "- Download url: #{definition.iso_src}"
            end
            env.ui.info "- Md5 Checksum: #{definition.iso_md5}"
            env.ui.info "#{definition.iso_download_instructions}"
            env.ui.info ""

            if definition.iso_src == ""
              env.ui.info "Please follow the instructions above:"
              env.ui.info "- to get the ISO"
              env.ui.info" - put it in <currentdir>/iso"
              env.ui.info "- then re-run the command"
              env.ui.info ""
              exit -1
            else

              question=env.ui.ask("Download? (Yes/No)") {|q| q.default="No"}
              if question.downcase == "yes"
                if !File.exists?(env.config.veewee.iso_dir)
                  env.ui.info "Creating an iso directory"
                  FileUtils.mkdir(env.config.veewee.iso_dir)
                end
                begin
                  download_progress(definition.iso_src,full_path)
                rescue OpenURI::HTTPError => ex
                  env.ui.error "There was an error downloading #{definition.iso_src}:"
                  env.ui.error "#{ex}"
                  exit -1
                end
              else
                env.ui.info "You have selected manual download: "
                env.ui.info "curl -C - -L '#{definition.iso_src}' -o '#{rel_path}'"
                env.ui.info "md5 '#{rel_path}' "
                env.ui.info ""
                exit
              end
              
              env.ui.info "Verifying md5 checksum : #{definition.iso_md5}"
              file_md5=hashsum(full_path)

              unless file_md5==definition.iso_md5
                env.ui.error "The MD5 checksums for file #{filename } do not match: "
                env.ui.error "- #{file_md5} (current) vs #{definition.iso_md5} (specified)"
                exit -1
              end

            end

          end

        end
      end #Module

    end #Module
  end #Module
end #Module
