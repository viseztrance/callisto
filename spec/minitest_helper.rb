require File.expand_path("../support/file_creator", __FILE__)
require File.expand_path("../support/singleton", __FILE__)
require File.expand_path("../lib/callisto", File.dirname(__FILE__))

def reset_pool
  Callisto::Pool.settings = {}
  Callisto::Pool.reset_instance
end
