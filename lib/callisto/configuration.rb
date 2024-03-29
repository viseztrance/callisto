require "delegate"

module Callisto

  class Configuration

    module Defaults

      POOL = {
        :identifier  => proc { |task| task.command },
        :callback    => proc { |task| task.run },
        :max_workers => 4
      }

      THUMBNAIL = {
        :quality => 90
      }

      SHELL = {}

    end

    attr_accessor :thumbnail_defaults

    def initialize
      reset
    end

    def reset
      self.thumbnail_defaults = Defaults::THUMBNAIL.clone
      Pool.settings = Defaults::POOL.clone
      Shell.bin_path = Defaults::SHELL.clone[:bin_path]
    end

    def max_workers=(val)
      Pool.settings.max_workers = val
    end

    def bin_path=(val)
      Shell.bin_path = val
    end

    def method_missing(method, *args, &block)
      if /^thumbnail_(?<name>[a-z\_]+)(?<setter>=)?/ =~ method
        if setter
          self.thumbnail_defaults[name.to_sym] = args.first
        else
          thumbnail_defaults[name.to_sym]
        end
      else
        super(method, *args, &block)
      end
    end

  end

end
