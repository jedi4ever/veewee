module Veewee
  module Builder
    module Virtualbox

      def add_shared_folder

        command="#{@vboxcmd} sharedfolder add  '#{@box_name}' --name 'veewee-validation' --hostpath '#{File.expand_path(@environment.validation_dir)}' --automount"
        Veewee::Util::Shell.execute("#{command}")

      end

    end
  end
end