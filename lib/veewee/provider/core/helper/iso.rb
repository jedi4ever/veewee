module Veewee
  module Provider
    module Core
      module Helper
        module Iso

          require 'open-uri'
          require 'progressbar'
          require 'highline/import'
          require 'digest/md5'
          require 'digest/sha1'
          require 'digest/sha2'

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
            uri = URI.parse(url)
            uri.open(
              :content_length_proc => lambda { |t|
                if t && 0 < t
                  pbar = ProgressBar.new("Fetching file", t)
                  pbar.file_transfer_mode
                end
              },
              :progress_proc => lambda {|s|
                pbar.set s if pbar
              },
              #consider proxy env vars only if host is not excluded
              :proxy => !no_proxy?(uri.host)
            ) { |src|
              if
                src.methods(&:to_sym).include?(:path)
              then
                # We assume large 10K files, so this is tempfile object
                ui.info "Moving #{src.path} to #{localfile}"
                # Force the close of the src stream to release handle before moving
                # Not forcing the close may cause an issue on windows (Permission Denied)
                src.close
                FileUtils.mv(src.path,localfile)
              else
                open(localfile,"wb") { |dst|
                  dst.write(src.read)
                }
              end
            }
          end

          #return true if host is excluded from proxy via no_proxy env var, false otherwise
          def no_proxy? host
            return false if host.nil?
            @no_proxy ||= (ENV['NO_PROXY'] || ENV['no_proxy'] || 'localhost, 127.0.0.1').split(/\s*,\s*/)
            @no_proxy.each do |host_addr|
              return true if host.match(Regexp.quote(host_addr)+'$')
            end
            return false
          end

          # Compute hash code
          def hashsum(filename,type)
            case type
            when :md5
              checksum=Digest::MD5.new
            when :sha1
              checksum=Digest::SHA1.new
            when :sha256
              checksum=Digest::SHA256.new
            else
              raise Veewee::Error, "Unknown checksum type #{type}"
            end

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

          def verify_sum(full_path,type)
            filename = File.basename(full_path)
            required_sum = self.instance_variable_get('@iso_'+type.to_s)
            ui.info "Verifying #{type} checksum : #{required_sum}"
            file_sum = hashsum(full_path,type)

            unless file_sum == required_sum
              ui.error "The #{type} checksum for file #{filename } do not match: "
              ui.error "- #{file_sum} (current) vs #{required_sum} (specified)"
              raise Veewee::Error, "The #{type} checksum for file #{filename } do not match: \n"+ "- #{file_sum} (current) vs #{required_sum} (specified)"
            end
          end

          def verify_iso(options)
            filename=self.iso_file
            full_path=File.join(env.config.veewee.iso_dir,filename)

            if File.exists?(full_path)
              ui.info ""
              ui.info "The isofile #{filename} already exists."
            else
              ui.info ""
              ui.info "We did not find an isofile here : #{full_path}. \n\nThe definition provided the following download information:"
              unless "#{self.iso_src}"==""
                ui.info "- Download url: #{self.iso_src}"
              end
              ui.info "- Md5 Checksum: #{self.iso_md5}" if self.iso_md5
              ui.info "- Sha1 Checksum: #{self.iso_sha1}" if self.iso_sha1
              ui.info "- Sha256 Checksum: #{self.iso_sha256}" if self.iso_sha256
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
                  ui.info "curl -C - -L '#{self.iso_src}' -o '#{full_path}'"
                  ui.info "md5 '#{full_path}' " if self.iso_md5
                  ui.info "shasum '#{full_path}' " if self.iso_sha1
                  ui.info "shasum -a 256 '#{rel_path}' " if self.iso_sha256
                  ui.info ""
                  exit
                end

                unless File.readable?(full_path)
                  raise Veewee::Error, "The provided iso #{full_path} is not readable"
                end

              end

            end

            verify_sum(full_path,:md5) if options["checksum"] && !self.iso_md5.nil?
            verify_sum(full_path,:sha1) if options["checksum"] && !self.iso_sha1.nil?
            verify_sum(full_path,:sha256) if options["checksum"] && !self.iso_sha256.nil?

          end
        end #Module

      end #Module
    end #Module
  end #Module
end #Module
