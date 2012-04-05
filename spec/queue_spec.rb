require "minitest/autorun"
require File.expand_path("../lib/callisto", File.dirname(__FILE__))
require File.expand_path("../minitest_helper", __FILE__)

describe "Queue" do

  before do
    Callisto::Queue.stack.replace([])
    Callisto::Queue.processes.replace({})
    Callisto::Queue.max_processes = 10
    Callisto::Queue.identity = false
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

  describe "when running the same (identical) task more than once" do

    before do
      Callisto::Queue.identity = proc { |task| task[:id] }
      Callisto::Queue.callback = proc { |task| task[:data].call }
    end

    it "should not run the task" do
      Callisto::Queue << { :id => 1, :data => proc { sleep 1 } }
      4.times {
        Callisto::Queue << { :id => 2, :data => proc { sleep 1 } }
      }
      Callisto::Queue.processes.count.must_equal 2
    end

    it "adding a task should return the original pid" do
      pid1 = Callisto::Queue << { :id => 1, :data => proc { sleep 1 } }
      pid2 = Callisto::Queue << { :id => 1, :data => proc { sleep 1 } }
      pid3 = Callisto::Queue << { :id => 2, :data => proc { sleep 1 } }
      pid1.must_equal pid2
      pid1.wont_equal pid3
    end

    it "should not stack duplicates" do
      Callisto::Queue.max_processes = 1
      Callisto::Queue << { :id => 1, :data => proc { sleep 1 } }
      4.times {
        Callisto::Queue << { :id => 2, :data => proc { sleep 1 } }
      }
      Callisto::Queue << { :id => 3, :data => proc { sleep 1 } }
      Callisto::Queue.stack.count.must_equal 2
    end

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

    before do
      Callisto::Queue.callback = proc { |task| task.call }
    end

    it "should be removed from the running list" do
      3.times {
        Callisto::Queue << proc { sleep 1 }
      }
      Callisto::Queue.processes.count.must_equal 3
      Callisto::Queue.wait
      Callisto::Queue.processes.count.must_equal 0
    end

    it "should run the first pending task"

    it "should remove pending task from the stack"

  end

end
