module Callisto

  class Shell

    attr_accessor :executable, :arguments

    def self.bin_path=(path)
      @@bin_path = path
    end

    def initialize(executable, arguments)
      self.executable = executable
      self.arguments = arguments
    end

    def command
      prefix = if defined?(@@bin_path)
                 File.join(@@bin_path, executable)
               else
                 executable
               end
      "#{prefix} #{arguments}"
    end

    def run
      `#{command}`.chomp
    end

  end

end
