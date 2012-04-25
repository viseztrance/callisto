$LOAD_PATH << File.dirname(__FILE__)

require "callisto/version"
require "callisto/configuration"
require "callisto/shell"
require "callisto/pool"
require "callisto/thumbnail"

module Callisto

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

end
