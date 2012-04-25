require "digest"
require "fileutils"

module Callisto

  class Thumbnail

    attr_accessor :file_path, :args, :flag
    attr_reader   :name, :crop
    attr_writer   :extension, :root_path, :prefix, :size, :quality

    def initialize(args = {})
      args.each do |name, value|
        self.send("#{name}=", value)
      end
      self.name = args
    end

    def name=(value)
      token = Digest::MD5.hexdigest(file_path.gsub(root_path, "") + value.to_s)
      @name = token + extension
    end

    def save
      location = File.join(root_path, prefix)
      return if File.exist?(save_path)
      FileUtils.mkdir_p(location) unless File.directory?(location)
      task = Shell.new("convert", "#{file_path} -strip -quality 90 -resize #{size}#{flag} #{crop} #{save_path}")
      pid = Callisto::Pool.instance << task
      Callisto::Pool.instance.wait(pid)
    end

    def save_path
      File.join(root_path, prefix, name)
    end

    def crop=(value)
      @crop = "-gravity Center -crop #{size}+0+0 +repage" if value
    end

    def extension
      @extension || Callisto.configuration.thumbnail_extension || File.extname(file_path)
    end

    %w(root_path prefix size quality).each do |attr|
      define_method attr do
        instance_variable_get("@#{attr}") || Callisto.configuration.send("thumbnail_#{attr}")
      end
    end

    def fixed_size=(val)
      self.min_size = val
      self.crop = true
    end

    def min_size=(val)
      self.flag = "^"
      self.size = val
    end

    def max_size=(val)
      self.size = val
      self.flag = "\\>"
      self.crop = true
    end

    def geometry
      task = Shell.new("identify", "-format \"%wx%h\" #{save_path}")
      task.run
    end

  end

end
