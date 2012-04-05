module Callisto

  class Queue

    attr_accessor :max_processes, :task
    @@stack = []
    @@processes = []
    @@max_processes = 10

    class << self

      def callback=(value)
        @@callback = value
      end

      def callback
        @@callback
      end

      def max_processes=(value)
        @@max_processes = value
      end

      def max_processes
        @@max_processes
      end

      def stack
        @@stack
      end

      def processes
        @@processes
      end

      def <<(task, options = {})
        entry = new(task)
        if processes.size < max_processes
          entry.process
        else
          self.stack << entry
        end
      end

      def wait
        sleep 0.1 while processes.any?
      end

    end

    def initialize(task)
      self.task = task
    end

    def process
      pid = fork do
        self.class.callback.call(task)
      end
      self.class.processes << pid
      Thread.new do
        Process.wait(pid)
        self.class.processes.delete(pid)
      end
    end

  end

end
