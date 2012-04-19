require "singleton"
require "ostruct"

module Callisto

  class Pool

    include Singleton

    attr_accessor :queue, :running, :pending, :workers

    class << self

      def settings=(options)
        defaults = {
          :max_workers => 10,
          :identifier  => proc { |entry| entry.object_id },
          :callback    => proc { |entry| entry.call }
        }
        @@settings = OpenStruct.new(defaults.merge(options))
      end

      def settings
        @@settings
      end

    end

    def initialize
      self.pending, self.running, self.workers = [], [], []
      self.queue = Queue.new
      1.upto(self.class.settings.max_workers) do
        worker = Thread.new do
          loop do
            task = self.queue.pop
            self.pending.delete self.class.settings.identifier.call(task)
            self.running << self.class.settings.identifier.call(task)
            self.class.settings.callback.call(task)
            self.running.delete self.class.settings.identifier.call(task)
          end
        end
        self.workers << worker
      end
    end

    def wait(id = nil)
      sleep(0.1) while (id ? processes.include?(id) : processes.any?)
    end

    def <<(task)
      identifier = self.class.settings.identifier.call(task)
      if !processes.include?(identifier)
        self.pending << identifier
        self.queue << task
      end
      identifier
    end

    def processes
      pending + running
    end

  end

end
