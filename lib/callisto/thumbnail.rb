require "digest"
require "fileutils"

module Callisto

  class Thumbnail

    attr_accessor :file_path, :root_path, :prefix, :args, :size, :flag

    attr_reader :name, :crop

    attr_writer :extension

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
      FileUtils.mkdir_p(location) unless File.directory?(location)
      %x[convert #{file_path} -strip -quality 90 -resize #{size}#{flag} #{crop} #{save_path}]
    end

    def save_path
      File.join(root_path, prefix, name)
    end

    def crop=(value)
      @crop = "-gravity Center -crop #{size}+0+0 +repage" if value
    end

    def extension
      @extension || File.extname(file_path)
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
      %x[identify -format "%wx%h" #{save_path}].chomp
    end

  end

end
