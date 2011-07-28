require 'veewee/util/shell'
require 'veewee/util/tcp'

module Veewee
  module Builder
    module Virtualbox

      def transaction(step_name,checksums,&block)

        current_step_nr=step_name.split("-")[0].to_i

        vm=VirtualBox::VM.find(@box_name)  
        snapnames=Array.new

        #If vm exists , look for snapshots
        if !vm.nil?
          start_snapshot=vm.root_snapshot
          snapshot=start_snapshot
          counter=0

          while (snapshot!=nil)
            #puts "#{counter}:#{snapshot.name}"
            snapnames[counter]=snapshot.name
            counter=counter+1  
            snapshot=snapshot.children[0]
          end 
        end

        #find the last snapshot matching the state
        counter=[snapnames.length, checksums.length].min-1
        last_good_state=counter
        for c in 0..counter do
          #puts "#{c}- #{snapnames[c]} - #{checksums[c]}"
          if !snapnames[c].match("#{c}.*-#{checksums[c]}")
            #        puts "we found a bad state"
            last_good_state=c-1
            break
          end  
        end
        #puts "Last good state: #{last_good_state}"

        if (current_step_nr < last_good_state)
          #puts "fast forwarding #{step_name}"
          return
        end

        #puts "Current step: #{current_step_nr}"
        if (current_step_nr == last_good_state)
          if vm.running?
            vm.stop
          end

          #invalidate later snapshots
          #puts "remove old snapshots"

          for s in (last_good_state+1)..(snapnames.length-1)
            puts "Removing step [#{s}] snapshot as it is no more valid"
            snapshot=vm.find_snapshot(snapnames[s])
            snapshot.destroy
            #puts snapshot
          end

          vm.reload
          puts "Loading step #{current_step_nr} snapshots as it has not changed"
          sleep 2
          goodsnap=vm.find_snapshot(snapnames[last_good_state])
          goodsnap.restore
          sleep 2
          #TODO:Restore snapshot!!!
          vm.start
          sleep 4
          puts "Starting machine"
        end

        #puts "last good state #{last_good_state}"


        if (current_step_nr > last_good_state)

          if (last_good_state==-1)
            #no initial snapshot is found, clean machine!
            vm=VirtualBox::VM.find(@box_name) 

            if !vm.nil?
              if vm.running?
                puts "Stopping machine"
                vm.stop
                while vm.running?
                  sleep 1
                end
              end

              #detaching cdroms (used to work in 3.x)
              #              vm.medium_attachments.each do |m|
              #                if m.type==:dvd
              #                  #puts "Detaching dvd"
              #                  m.detach
              #                end
              #              end

              vm.reload
              puts "We found no good state so we are destroying the previous machine+disks"
              destroy
            end

          end

          #puts "(re-)executing step #{step_name}"


          yield

          #Need to look it up again because if it was an initial load
          vm=VirtualBox::VM.find(@box_name) 
          puts "Step [#{current_step_nr}] was succesfully - saving state"
          vm.save_state
          sleep 2 #waiting for it to be ok
          #puts "about to snapshot #{vm}"
          #take snapshot after succesful execution
          vm.take_snapshot(step_name,"snapshot taken by veewee")
          sleep 2 #waiting for it to be started again
          vm.start
        end   

        #pp snapnames
      end
      
      def transaction(step_name,checksums,&block)
        yield
      end
    end #Module
  end #Module
end #Module
