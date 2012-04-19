require "tmpdir"
require "fileutils"

class FileCreator

  attr_accessor :file_name

  def initialize(value)
    self.file_name = value
  end

  def save(wait = 0)
    sleep wait
    FileUtils.touch path
  end

  def path
    File.join(Dir.tmpdir, file_name)
  end

end

# Reset singleton
# http://blog.ardes.com/2006/12/11/testing-singletons-with-ruby

require "singleton"
class << Singleton

  def included_with_reset(klass)

    included_without_reset(klass)

    class << klass

      def reset_instance
        Singleton.send :__init__, self
        self
      end

    end

  end

  alias_method :included_without_reset, :included

  alias_method :included, :included_with_reset

end
