module Callisto

  class Queue

    attr_accessor :max_processes, :task, :pid
    @@stack         = []
    @@processes     = {}
    @@max_processes = 10
    @@identity      = false

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
        self.stack << entry
        if processes.size < max_processes
          entry.process
        else
          nil # Task is pending
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
      self.class.stack.delete(self)
      self.pid = fork do
        self.class.callback.call(task)
      end
      self.class.processes[pid] = task
      Thread.new do
        Process.wait(pid)
        destroy
      end
      pid
    end

    def destroy
      self.class.processes.delete(pid)
    end

  end

end
