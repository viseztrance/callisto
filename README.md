# Callisto

A library that generates thumbnails on the fly. Requires the ImageMagick command line utility to be installed.

## Installation

Add this line to your application's Gemfile:

    gem 'callisto'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install callisto

## Usage

A thumbnail may be generated as follows:

    options = {
      :root_path        => Rails.root,
      :prefix           => "public/images/cache",
      :public_path      => "/images/cache",
      :fixed_size       => "140x90"
    }
    thumbnail = Callisto::Thumbnail.new(options)
    thumbnail.save # Returns the file name using the `public_path`

The image name generated is based on the parameters used. However the `root_path` will always be ignored, in order to allow the application path to be changed without having to regenerate the thumbnails (eg. this always happens after a deploy when using capistrano).

The `fixed_size` option will scale the image then crop it to fit the specified dimension.
You may also resize the photo without cropping it by using either the `min_size` or `max_size` options. `min_size` will scale down the photo while ensuring that neither the width or height is less than the specified value, whereas `max_size` does the opposite.

You may also set defaults or set additional options buy using a `configure` block:

    Callisto.configure do |config|
      config.thumbnail_root_path   = Rails.root
      config.thumbnail_prefix      = "public/images/cache"
      config.bin_path              = "/usr/local/bin"
      config.max_workers           = 4
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request