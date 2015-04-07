require 'net/http'
    
# Change the file for definitionVariation to one of the .yml configurations in this directory for the box you would like to build.
definitionVariation = 'gentoo_amd64.yml'

Veewee::Definition.declare_yaml('definition.yml', definitionVariation)

file = YAML.load_file(definitionVariation);
arch = file[:architecture]

template_uri   = "http://distfiles.gentoo.org/releases/#{arch}/autobuilds/latest-install-#{arch}-minimal.txt"
template_build = Net::HTTP.get_response(URI.parse(template_uri)).body.split(/\n/).last.split(/\ /)

Veewee::Definition.declare({
    :iso_file    => template_build.first.split(/\//).last,
    :iso_src     => "http://distfiles.gentoo.org/releases/#{arch}/autobuilds/#{template_build.first}"
})
