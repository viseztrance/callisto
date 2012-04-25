require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Callisto" do

  it "should have a configuration" do
    Callisto.configuration.must_be_instance_of Callisto::Configuration
  end

  it "must cache configuration" do
    Callisto.configuration.object_id.must_equal Callisto.configuration.object_id
  end

  it "yields the current configuration" do
    Callisto.configure do |config|
      config.must_equal Callisto.configuration
    end
  end

end
