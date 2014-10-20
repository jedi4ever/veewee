require "gem-content"

module Veewee
  class Templates

    attr_accessor :env

    def initialize(env)
      @env = env
      return self
    end

    def [](name)
      result = nil
      valid_paths(env.template_path).each do |template_dir|
        template = Veewee::Template.new(name, File.join(template_dir, name), @env)
        if template.exists?
          result = template
          return result
        end
      end
      return nil
    end

    # Fetch all Templates
    def each(&block)
      templates = Hash.new

      valid_paths(env.template_path).each do |template_dir|

        env.logger.debug("[Template] Searching #{template_dir} for templates")

        subdirs = Dir.glob("#{template_dir}/*")
        subdirs.each do |sub|
          if File.directory?("#{sub}")
            name = sub.sub(/#{template_dir}\//, '')
            template = Veewee::Template.new(name, sub, @env)
            if template.exists?
              env.logger.debug("[Template] template '#{name}' found")
              templates[name] = template
            end
          end
        end
      end

      if templates.length == 0
        env.logger.debug("[Template] no templates found")
      end

      Hash[templates.sort].each(&block)
    end

    private

    # Traverses path to see which exist or not
    # and checks if available
    def valid_paths(paths)
      paths = GemContent.get_gem_paths("veewee-templates")
      valid_paths = paths.collect { |path|
        if File.exists?(path) && File.directory?(path)
          env.logger.info "Path #{path} exists"
          File.expand_path(path)
        else
          env.logger.info "Path #{path} does not exist, skipping"
          nil
        end
      }
      return valid_paths.compact
    end

  end
end
