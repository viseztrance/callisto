module Callisto

  class Shell

    attr_accessor :executable, :arguments

    def self.bin_path=(path)
      @bin_path = path
    end

    def self.bin_path
      @bin_path
    end

    def initialize(executable, arguments)
      self.executable = executable
      self.arguments = arguments
    end

    def command
      prefix = File.join(*[self.class.bin_path, executable].compact)
      "#{prefix} #{arguments}"
    end

    def run
      `#{command}`.chomp
    end

  end

end
