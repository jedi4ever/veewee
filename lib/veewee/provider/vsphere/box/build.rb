module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def build(options)
          env.ui.warn "Boot wait is less than 10 seconds...build may fail" if Integer(definition.boot_wait) < 10
          validate_host
          super(options)
          close_vnc
        end

        # Validate the host configuration is set before
        # building the VM
        def validate_host
          # Check we have a host IP to use
          self.host_ip_as_seen_by_guest
        end

        def handle_kickstart(options)
          super(options)

          question = nil
          until !self.ip_address.nil? || !question.nil?
            env.logger.info "wait for Ip address"
            sleep 2

            # Verify there isn't a question blocking execution
            env.logger.info "checking for questions"
            question = raw.runtime.question
          end

          unless question.nil?
            # If the question is a cdromdisconnect from the installation,
            # answer the question with "Yes" ( value is 0 )
            if question.text =~ /msg\.cdromdisconnect\.locked/
              raw.AnswerVM(:questionId => question.id, :answerChoice => "0")
            else
              raise Veewee::Error, "Unanswerable VM Question '#{question.id}' encountered\n#{question.text}"
            end
          end

        end

      end
    end
  end
end
