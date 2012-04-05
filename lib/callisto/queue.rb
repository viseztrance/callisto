module Callisto

  class Queue

    attr_accessor :max_processes, :task
    @@stack         = []
    @@processes     = {}
    @@max_processes = 10
    @@identity       = false

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

      def identity=(value)
        @@identity = value
      end

      def identity
        @@identity
      end

      def <<(task, options = {})
        entry = new(task)
        if identity # Ensure that the task hasn't been already enqueued
          processes.each { |pid, running_task| return pid if entry.has?(running_task) }
          stack.each { |current_entry| return nil if entry.has?(current_entry.task) }
        end
        if processes.size < max_processes
          entry.process
        else
          self.stack << entry
          nil
        end
      end

      def wait
        sleep 0.1 while processes.any?
      end

    end

    def initialize(task)
      self.task = task
    end

    def has?(value)
      self.class.identity.call(task) == self.class.identity.call(value)
    end

    def process
      pid = fork do
        self.class.callback.call(task)
      end
      self.class.processes[pid] = task
      Thread.new do
        Process.wait(pid)
        self.class.processes.delete(pid)
      end
      pid
    end

  end

end
