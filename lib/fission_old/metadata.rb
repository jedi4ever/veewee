module Fission
  class Metadata

    require 'cfpropertylist'

    attr_accessor :content

    def self.delete_vm_info(vm_path)
      metadata = new
      metadata.load
      metadata.delete_vm_restart_document(vm_path)
      metadata.delete_vm_favorite_entry(vm_path)
      metadata.save
    end

    def load
      raw_data = CFPropertyList::List.new :file => Fission.config.attributes['plist_file']
      @content = CFPropertyList.native_types raw_data.value
    end

    def save
      new_content = CFPropertyList::List.new
      new_content.value = CFPropertyList.guess @content
      new_content.save Fission.config.attributes['plist_file'],
        CFPropertyList::List::FORMAT_BINARY
    end

    def delete_vm_restart_document(vm_path)
      if @content.has_key?('PLRestartDocumentPaths')
        @content['PLRestartDocumentPaths'].delete_if { |p| p == vm_path }
      end
    end

    def delete_vm_favorite_entry(vm_path)
      @content['VMFavoritesListDefaults2'].delete_if { |vm| vm['path'] == vm_path }
    end

  end
end
