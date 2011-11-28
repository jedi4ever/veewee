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
              env.ui.info "Creating an iso directory"
              FileUtils.mkdir(env.config.veewee.iso_dir)
            end
            env.ui.info "Checking if isofile #{filename} already exists."
            full_path=File.join(env.config.veewee.iso_dir,filename)
            env.ui.info "Full path: #{full_path}"
            if File.exists?(full_path)
              env.ui.info ""
              env.ui.info "The isofile #{filename} already exists."
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
              env.ui.info "Moving #{src.path} to #{localfile}"
              FileUtils.mv(src.path,localfile)
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
                env.ui.info('.',{:new_line => false}) if ((counter+=1) % 20000 == 0)
                checksum.update(readBuf)
              end
            end
            return checksum.hexdigest
          end


          def verify_iso(options)
            filename=self.iso_file
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
              unless "#{self.iso_src}"==""
                env.ui.info "- Download url: #{self.iso_src}"
              end
              env.ui.info "- Md5 Checksum: #{self.iso_md5}"
              env.ui.info "#{self.iso_download_instructions}"
              env.ui.info ""

              if self.iso_src == ""
                env.ui.info "Please follow the instructions above:"
                env.ui.info "- to get the ISO"
                env.ui.info" - put it in <currentdir>/iso"
                env.ui.info "- then re-run the command"
                env.ui.info ""
                raise Veewee::Error, "No ISO src is available, can't download it automatically"
              else
                answer=nil
                answer="yes" if options["auto"]==true
                env.logger.info "Auto download enabled?#{answer} #{!options['auto'].nil?}"
                if answer.nil?
                  answer=env.ui.ask("Download? (Yes/No)") {|q| q.default="No"}
                end

                if answer.downcase == "yes"
                  begin
                    download_iso(self.iso_src,full_path)
                  rescue OpenURI::HTTPError => ex
                    env.ui.error "There was an error downloading #{self.iso_src}:"
                    env.ui.error "#{ex}"
                    raise Veewee::Error, "There was an error downloading #{self.iso_src}:\n#{ex}"
                  end
                else
                  env.ui.info "You have selected manual download: "
                  env.ui.info "curl -C - -L '#{self.iso_src}' -o '#{rel_path}'"
                  env.ui.info "md5 '#{rel_path}' "
                  env.ui.info ""
                  exit
                end

                env.ui.info "Verifying md5 checksum : #{self.iso_md5}"
                file_md5=hashsum(full_path)

                unless file_md5==self.iso_md5
                  env.ui.error "The MD5 checksums for file #{filename } do not match: "
                  env.ui.error "- #{file_md5} (current) vs #{self.iso_md5} (specified)"
                  raise Veewee::Error, "The MD5 checksums for file #{filename } do not match: \n"+ "- #{file_md5} (current) vs #{self.iso_md5} (specified)"
                end

              end

            end

          end
        end #Module

      end #Module
    end #Module
  end #Module
end #Module
