require 'grit'

module Veewee
	class GritGitProvider < GitInterface
		def clone(uri, dst_dir)
		  g = Grit::Git.new(dst_dir)
          g.clone({ :timeout => false }, uri, dst_dir)
        end
	end
end