require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Configuration" do

  before do
    Callisto.configuration.reset
  end

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

  it "can be reset" do
    default_size = Callisto::Configuration::Defaults::THUMBNAIL[:size]
    default_quality = Callisto::Configuration::Defaults::THUMBNAIL[:quality]
    Callisto.configure do |config|
      config.thumbnail_size = "20x45"
      config.thumbnail_quality = 75
    end
    Callisto.configuration.reset
    Callisto.configuration.thumbnail_size.must_equal default_size
    Callisto.configuration.thumbnail_quality.must_equal default_quality
  end

end
