#if RUBY_VERSION =~ /1.9/
    #Encoding.default_external = Encoding::UTF_8
    #Encoding.default_internal = Encoding::UTF_8
#end

source "http://rubygems.org"

#gem "veewee", :path => "."
#gem "fission", :path => '/Users/patrick/dev/fission'

group :kvm do
  gem "ruby-libvirt"
end

group :windows do
  gem "em-winrm", :git => 'https://github.com/hh/em-winrm.git', :ref => '31745601d3'
  gem "log4r"
end

group :test do
  gem "rake"
  #gem "vagrant" , "1.0.7"
  #gem "chef"
  #gem "knife-windows"
end

gemspec
