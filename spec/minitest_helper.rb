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
