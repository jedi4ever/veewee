module Veewee
  module Provider
    module Core
      module Helper
        module Iso

          require 'open-uri'
          require 'progressbar'
          require 'highline/import'
          require 'digest/md5'

          def download_iso(url,filename)
            if !File.exists?(env.config.veewee.iso_dir)
              ui.info "Creating an iso directory"
              FileUtils.mkdir(env.config.veewee.iso_dir)
            end
            ui.info "Checking if isofile #{filename} already exists."
            full_path=File.join(env.config.veewee.iso_dir,filename)
            ui.info "Full path: #{full_path}"
            if File.exists?(full_path)
              ui.info ""
              ui.info "The isofile #{filename} already exists."
            else
              download_progress(url,full_path)
            end
          end

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
              # We assume large 10K files, so this is tempfile object
              env.logger.info "#{src.class}"
                ui.info "Moving #{src.path} to #{localfile}"
                # Force the close of the src stream to release handle before moving
                # Not forcing the close may cause an issue on windows (Permission Denied)
                src.close
                FileUtils.mv(src.path,localfile)
                #open(localfile,"wb") { |dst|
                  #dst.write(src.read)
                #}
            }
          end

          # Compute hash code
          def hashsum(filename)
            checksum=Digest::MD5.new
            buflen=1024
            open(filename, "rb") do |io|
              counter = 0
              while (!io.eof)
                readBuf = io.readpartial(buflen)
                env.ui.info('.',{:new_line => false,:prefix => false }) if ((counter+=1) % 20000 == 0)
                checksum.update(readBuf)
              end
            end
            return checksum.hexdigest
          end

          def verify_md5sum(full_path)
            filename = File.basename(full_path)
            ui.info "Verifying md5 checksum : #{self.iso_md5}"
            file_md5=hashsum(full_path)

            unless file_md5==self.iso_md5
              ui.error "The MD5 checksums for file #{filename } do not match: "
              ui.error "- #{file_md5} (current) vs #{self.iso_md5} (specified)"
              raise Veewee::Error, "The MD5 checksums for file #{filename } do not match: \n"+ "- #{file_md5} (current) vs #{self.iso_md5} (specified)"
            end
          end

          def verify_iso(options)
            filename=self.iso_file
            full_path=File.join(env.config.veewee.iso_dir,filename)

            if File.exists?(full_path)
              ui.info ""
              ui.info "The isofile #{filename} already exists."
            else

              path1=Pathname.new(full_path)
              path2=Pathname.new(Dir.pwd)
              rel_path=path1.relative_path_from(path2).to_s

              ui.info ""
              ui.info "We did not find an isofile in <currentdir>/iso. \n\nThe definition provided the following download information:"
              unless "#{self.iso_src}"==""
                ui.info "- Download url: #{self.iso_src}"
              end
              ui.info "- Md5 Checksum: #{self.iso_md5}"
              ui.info "#{self.iso_download_instructions}"
              ui.info ""

              if self.iso_src == ""
                ui.info "Please follow the instructions above:"
                ui.info "- to get the ISO"
                ui.info" - put it in <currentdir>/iso"
                ui.info "- then re-run the command"
                ui.info ""
                raise Veewee::Error, "No ISO src is available, can't download it automatically"
              else
                answer=nil
                answer="yes" if options["auto"]==true
                env.logger.info "Auto download enabled?#{answer} #{!options['auto'].nil?}"
                if answer.nil?
                  answer=ui.ask("Download? (Yes/No)") {|q| q.default="No"}
                end

                if answer.downcase == "yes"
                  begin
                    download_iso(self.iso_src,filename)
                  rescue OpenURI::HTTPError => ex
                    ui.error "There was an error downloading #{self.iso_src}:"
                    ui.error "#{ex}"
                    raise Veewee::Error, "There was an error downloading #{self.iso_src}:\n#{ex}"
                  end
                else
                  ui.info "You have selected manual download: "
                  ui.info "curl -C - -L '#{self.iso_src}' -o '#{rel_path}'"
                  ui.info "md5 '#{rel_path}' "
                  ui.info ""
                  exit
                end

                unless File.readable?(full_path)
                  raise Veewee::Error, "The provided iso #{full_path} is not readable"
                end

              end

            end

            verify_md5sum(full_path) if options["md5check"] && !self.iso_md5.nil?

          end
        end #Module

      end #Module
    end #Module
  end #Module
end #Module
