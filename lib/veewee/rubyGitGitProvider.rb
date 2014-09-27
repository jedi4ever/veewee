require 'rubygems'
require 'git'

module Veewee
	class RubyGitGitProvider < GitInterface
		def clone(uri, dst_dir)
		  directory_name = File.basename(dst_dir)
		  g = Git.clone(uri, :name => directory_name, :path => dst_dir) 
        end
	end
end