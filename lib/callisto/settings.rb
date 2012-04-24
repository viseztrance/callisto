module Callisto

  class Configuration

    def self.load!
      Callisto::Pool.settings = {
        :identifier => proc { |task| task.command },
        :callback   => proc { |task| task.run }
      }
    end

    # Templates

    # Image quality

    # Threads

  end

end
