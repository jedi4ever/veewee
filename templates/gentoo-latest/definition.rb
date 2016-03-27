require 'net/http'
    
# Change the file for definitionVariation to one of the .yml configurations in this directory for the box you would like to build.
definitionVariation = 'gentoo_amd64_minimal.yml'

Veewee::Definition.declare_yaml('definition.yml', definitionVariation)

file = YAML.load_file(definitionVariation);
arch = file[:architecture]

template_uri   = "http://distfiles.gentoo.org/releases/#{arch}/autobuilds/latest-install-#{arch}-minimal.txt"
template_build = Net::HTTP.get_response(URI.parse(template_uri)).body.split(/\n/).last.split(/\ /)

# If you are finding you need to run this process many times, manually download the stage3 and portage file
# and tar them together as postinstall-gentoo.tar in your veewee working directory then uncomment the hooks
# lines below. Refer to setting_*.sh for how to determine the URL for the appropriate stage3 and portage files.

Veewee::Definition.declare({
#     :cpu_count   => '2',
#     :memory_size => '4096',
    :iso_file    => template_build.first.split(/\//).last,
    :iso_src     => "http://distfiles.gentoo.org/releases/#{arch}/autobuilds/#{template_build.first}",
#     :hooks       => {
#         :before_postinstall => Proc.new { definition.box.scp('postinstall-gentoo.tar', 'postinstall-gentoo.tar') }
#     }
})
