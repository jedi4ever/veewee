module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        VIM = RbVmomi::VIM
        NET_DEVICE_CLASSES = {
          'e1000' => VIM::VirtualE1000,
          'vmxnet3' => VIM::VirtualVmxnet3,
        }

        def add_net network, opts
          klass = NET_DEVICE_CLASSES[opts[:type]] or err "unknown network adapter type #{opts[:type].inspect}"

          case network
            when VIM::DistributedVirtualPortgroup
              switch, pg_key = network.collect 'config.distributedVirtualSwitch', 'key'
              port = VIM.DistributedVirtualSwitchPortConnection(
                :switchUuid => switch.uuid,
                :portgroupKey => pg_key)
              summary = network.name
              backing = VIM.VirtualEthernetCardDistributedVirtualPortBackingInfo(:port => port)
            when VIM::Network
              summary = network.name
              backing = VIM.VirtualEthernetCardNetworkBackingInfo(:deviceName => network.name)
            else fail
          end

          _add_device raw, nil, klass.new(
            :key => -1,
            :deviceInfo => {
              :summary => summary,
              :label => "",
            },
            :backing => backing,
            :addressType => 'generated'
          )
        end

        def add_disk size
          vm = raw
          controller, unit_number = pick_controller vm, nil, [VIM::VirtualSCSIController]
          id = "disk-#{controller.key}-#{unit_number}"

          filename = "#{File.dirname(vm.summary.config.vmPathName)}/#{id}.vmdk"

          _add_device vm, 'create', VIM::VirtualDisk(
            :key => -1,
            :backing => VIM.VirtualDiskFlatVer2BackingInfo(
              :fileName => filename,
              :diskMode => :persistent,
              :thinProvisioned => true
            ),
            :capacityInKB => MetricNumber.parse(size).to_i/1000,
            :controllerKey => controller.key,
            :unitNumber => unit_number
          )
        end

        def pick_controller vm, controller, controller_classes
          existing_devices, = vm.collect 'config.hardware.device'

          controller ||= existing_devices.find do |dev|
            controller_classes.any? { |klass| dev.is_a? klass } &&
              dev.device.length < 2
          end
          err "no suitable controller found" unless controller

          used_unit_numbers = existing_devices.select { |dev| dev.controllerKey == controller.key }.map(&:unitNumber)
          unit_number = (used_unit_numbers.max||-1) + 1

          [controller, unit_number]
        end
        
        def _add_device vm, fileOp, dev
          spec = {
            :deviceChange => [
              { :operation => :add, :fileOperation => fileOp, :device => dev },
            ]
          }
          task = vm.ReconfigVM_Task(:spec => spec).wait_for_completion
          #result = progress([task])[task]
          #result = nil
          #if result == nil
            #new_device = vm.collect('config.hardware.device')[0].grep(dev.class).last
            #puts "Added device #{new_device.name}"
          #end
        end

        require "delegate"

        class MetricNumber < SimpleDelegator
          attr_reader :unit, :binary

          def initialize val, unit, binary=false
            @unit = unit
            @binary = binary
            super val.to_f
          end

          def to_s
            limit = @binary ? 1024 : 1000
            if self < limit
              prefix = ''
              multiple = 1
            else
              prefixes = @binary ? BINARY_PREFIXES : DECIMAL_PREFIXES
              prefixes = prefixes.sort_by { |k,v| v }
              prefix, multiple = prefixes.find { |k,v| self/v < limit }
              prefix, multiple = prefixes.last unless prefix
            end
            ("%0.2f %s%s" % [self/multiple, prefix, @unit]).strip
          end

          # http://physics.nist.gov/cuu/Units/prefixes.html
          DECIMAL_PREFIXES = {
            'k' => 10 ** 3,
            'M' => 10 ** 6,
            'G' => 10 ** 9,
            'T' => 10 ** 12,
            'P' => 10 ** 15,
           }
           
           # http://physics.nist.gov/cuu/Units/binary.html
          BINARY_PREFIXES = {
            'Ki' => 2 ** 10,
            'Mi' => 2 ** 20,
            'Gi' => 2 ** 30,
            'Ti' => 2 ** 40,
            'Pi' => 2 ** 50,
          }
           
          CANONICAL_PREFIXES = Hash[(DECIMAL_PREFIXES.keys + BINARY_PREFIXES.keys).map { |x| [x.downcase, x] }]
           
          def self.parse str
            if str =~ /^([0-9,.]+)\s*([kmgtp]i?)?/i
              x = $1.delete(',').to_f
              binary = false
              if $2
                prefix = $2.downcase
                binary = prefix[1..1] == 'i'
                prefixes = binary ? BINARY_PREFIXES : DECIMAL_PREFIXES
                multiple = prefixes[CANONICAL_PREFIXES[prefix]]
              else
                multiple = 1
              end
              units = $'
              new x*multiple, units, binary
            else
              raise "Problem parsing SI number #{str.inspect}"
            end
          end
        end
      end
    end
  end
end
