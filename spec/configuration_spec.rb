require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Configuration" do

  it "should assign max workers to pool" do
    Callisto.configure do |config|
      config.max_workers = 13
    end
    Callisto::Pool.settings.max_workers.must_equal 13
  end

  it "should assign thumbnail defaults" do
    Callisto.configure do |config|
      config.thumbnail_size = "20x45"
      config.thumbnail_quality = 75
    end

    Callisto.configuration.thumbnail_size.must_equal "20x45"
    Callisto.configuration.thumbnail_quality.must_equal 75
  end

end
