module Callisto

  class Configuration

    module Defaults

      POOL = {
        :identifier  => proc { |task| task.command },
        :callback    => proc { |task| task.run },
        :max_workers => 4
      }

    end

    attr_accessor :thumbnail_defaults

    def initialize
      self.thumbnail_defaults = {}
      load_defaults
    end

    def load_defaults
      Pool.settings = Defaults::POOL
    end

    def max_workers=(val)
      Pool.settings.max_workers = val
    end

    def method_missing(method, *args, &block)
      if method.match(/^thumbnail_(\w+)(=)?/)
        name, setter = $1, $2
        if setter
          self.thumbnail_defaults[name] = args.first
        else
          thumbnail_defaults[name]
        end
      else
        super
      end
    end

  end

end
