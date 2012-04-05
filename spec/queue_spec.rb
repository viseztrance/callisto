require "minitest/autorun"
require File.expand_path("../lib/callisto", File.dirname(__FILE__))
require File.expand_path("../minitest_helper", __FILE__)

describe "Queue" do

  after do
    Callisto::Queue.stack.replace([])
    Callisto::Queue.processes.replace([])
    Callisto::Queue.max_processes = 10
  end

  it "should run a task" do
    file = FileCreator.new("callback.txt")
    Callisto::Queue.callback = proc { |task| task.save }
    Callisto::Queue << file
    Callisto::Queue.wait
    File.exist?(file.path).must_equal true
    File.unlink(file.path)
  end

  it "should run tasks in parallel" do
    file1 = FileCreator.new("file1.txt")
    file2 = FileCreator.new("file2.txt")
    file3 = FileCreator.new("file3.txt")
    Callisto::Queue.callback = proc { |task| task.save(1.0) }
    start_time = Time.now
    Callisto::Queue << file1
    Callisto::Queue << file2
    Callisto::Queue << file3
    Callisto::Queue.wait
    end_time = Time.now
    (end_time - start_time).must_be :<, 2
    File.exist?(file1.path).must_equal true
    File.exist?(file2.path).must_equal true
    File.exist?(file3.path).must_equal true
    File.unlink(file1.path)
    File.unlink(file2.path)
    File.unlink(file3.path)
  end

  describe "when max tasks reached" do

    before do
      Callisto::Queue.max_processes = 2
      Callisto::Queue.callback = proc { |task| task.call }
    end

    it "should not run more than the max allowed processes at the same time" do
      3.times {
        Callisto::Queue << proc { sleep 1 }
      }
      Callisto::Queue.processes.count.must_equal 2
    end

    it "should stack incoming tasks" do
      5.times {
        Callisto::Queue << proc { sleep 1 }
      }
      Callisto::Queue.stack.count.must_equal 3
    end

  end

  describe "when task is finished" do

    it "should be removed from the running list"

    it "should run the first pending task"

    it "should remove pending task from the stack"

  end

end
