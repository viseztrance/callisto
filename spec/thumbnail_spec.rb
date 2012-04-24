require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)
require File.expand_path("../lib/callisto", File.dirname(__FILE__))

def cleanup(path)
  matcher = File.join(path, "*.*")
  Dir[matcher].each { |entry| File.unlink(entry) }
end

describe "Thumbnail" do

  describe "when saving" do

    before do
      @options = {
        :file_path => File.expand_path("fixtures/normal-photo.png", File.dirname(__FILE__)),
        :root_path => File.expand_path("../tmp", File.dirname(__FILE__)),
        :prefix    => "images",
        :size      => "50x50",
        :extension => ".jpg"
      }
    end

    after do
      cleanup(File.join(@options[:root_path], @options[:prefix]))
    end

    it "should write the file at the specified location" do
      thumbnail = Callisto::Thumbnail.new(@options)
      File.exist?(thumbnail.save_path).must_equal false
      thumbnail.save
      File.exist?(thumbnail.save_path).must_equal true
    end

    it "should change file extension to the new value" do
      @options.merge!(:extension => ".gif")
      thumbnail = Callisto::Thumbnail.new(@options)
      File.extname(thumbnail.save_path).must_equal ".gif"
    end

    it "should preserve file extension" do
      @options.delete(:extension)
      thumbnail = Callisto::Thumbnail.new(@options)
      thumbnail.save
      File.extname(thumbnail.save_path).must_equal ".png"
      File.exist?(thumbnail.save_path).must_equal true
    end

  end

  describe "resizing the image" do

    before do
      @options = {
        :file_path => File.expand_path("fixtures/normal-photo.png", File.dirname(__FILE__)),
        :root_path => File.expand_path("../tmp", File.dirname(__FILE__)),
        :prefix    => "images"
      }
    end

    after do
      cleanup(File.join(@options[:root_path], @options[:prefix]))
    end

    it "should scale image to the specified size" do
      @options.merge!({ :fixed_size => "50x50" })
      thumbnail = Callisto::Thumbnail.new(@options)
      thumbnail.save
      thumbnail.geometry.must_equal "50x50"
    end

    it "should scale image within the specified size" do
      @options.merge!({ :max_size => "50x50" })
      thumbnail = Callisto::Thumbnail.new(@options)
      thumbnail.save
      thumbnail.geometry.must_equal "50x31"
    end

    it "should scale image larger then specified size" do
      @options.merge!({ :min_size => "50x50" })
      thumbnail = Callisto::Thumbnail.new(@options)
      thumbnail.save
      thumbnail.geometry.must_equal "80x50"
    end

  end

end
