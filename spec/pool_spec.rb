require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Pool" do

  before do
    reset_pool
  end

  describe "when assigning a task" do

    before do
      Callisto::Pool.settings = {
        :max_workers => 10,
        :identifier => proc { |task| task.path },
        :callback => proc { |task| task.save }
      }
    end

    it "should run a task" do
      file = FileCreator.new("callback.txt")
      Callisto::Pool.instance << file
      Callisto::Pool.instance.wait
      File.exist?(file.path).must_equal true
      File.unlink(file.path)
    end

    it "should run tasks in parallel" do
      file1 = FileCreator.new("file1.txt")
      file2 = FileCreator.new("file2.txt")
      file3 = FileCreator.new("file3.txt")
      Callisto::Pool.settings.callback = proc { |task| task.save(1.0) }
      start_time = Time.now
      Callisto::Pool.instance << file1
      Callisto::Pool.instance << file2
      Callisto::Pool.instance << file3
      Callisto::Pool.instance.wait
      end_time = Time.now
      (end_time - start_time).must_be :<, 2
      File.exist?(file1.path).must_equal true
      File.exist?(file2.path).must_equal true
      File.exist?(file3.path).must_equal true
      File.unlink(file1.path, file2.path, file3.path)
    end

  end

  describe "when running the same (identical) task more than once" do

    before do
      Callisto::Pool.settings = {
        :identifier => proc { |task| task[:id] },
        :callback => proc { |task| task[:data].call }
      }
    end

    it "adding a task should return the id" do
      id1 = Callisto::Pool.instance << { :id => 1, :data => proc { sleep 1 } }
      id2 = Callisto::Pool.instance << { :id => 1, :data => proc { sleep 1 } }
      id3 = Callisto::Pool.instance << { :id => 2, :data => proc { sleep 1 } }
      sleep 0.1
      id1.must_equal id2
      id1.wont_equal id3
    end

    it "should not run the task" do
      Callisto::Pool.instance << { :id => 1, :data => proc { sleep 1 } }
      4.times {
        Callisto::Pool.instance << { :id => 2, :data => proc { sleep 1 } }
      }
      sleep 0.1
      Callisto::Pool.instance.running.count.must_equal 2
    end

    it "should not stack duplicates" do
      Callisto::Pool.instance << { :id => 1, :data => proc { sleep 1 } }
      4.times {
        Callisto::Pool.instance << { :id => 2, :data => proc { sleep 1 } }
      }
      Callisto::Pool.instance << { :id => 3, :data => proc { sleep 1 } }
      Callisto::Pool.instance.processes.count.must_equal 3
    end

  end

  describe "when max tasks reached" do

    before do
      Callisto::Pool.settings.max_workers = 2
    end

    it "should not run more than the max allowed processes at the same time" do
      3.times {
        Callisto::Pool.instance << proc { sleep 1 }
      }
      sleep 0.1
      Callisto::Pool.instance.running.count.must_equal 2
    end

    it "should stack incoming tasks" do
      5.times {
        Callisto::Pool.instance << proc { sleep 1 }
      }
      sleep 0.1
      Callisto::Pool.instance.pending.count.must_equal 3
    end

  end

  describe "when task is finished" do

    it "should be removed from the running list" do
      3.times {
        Callisto::Pool.instance << proc { sleep 1 }
      }
      sleep 0.1
      Callisto::Pool.instance.running.count.must_equal 3
      Callisto::Pool.instance.wait
      Callisto::Pool.instance.running.count.must_equal 0
    end

    it "should run the first pending task" do
      Callisto::Pool.settings = {
        :max_workers => 1,
        :callback => proc { |task| task.save(0.5) }
      }
      file1 = FileCreator.new("file1.txt")
      file2 = FileCreator.new("file2.txt")
      Callisto::Pool.instance << file1
      Callisto::Pool.instance << file2
      sleep 0.1
      Callisto::Pool.instance.running.count.must_equal 1
      Callisto::Pool.instance.wait
      File.exist?(file1.path).must_equal true
      File.exist?(file2.path).must_equal true
      File.unlink(file1.path, file2.path)
    end

    it "should remove pending task from the stack" do
      Callisto::Pool.settings = {
        :max_workers => 1,
        :identifier => proc { |task| task[:id] },
        :callback => proc { |task| task[:data].call }
      }
      id1 = Callisto::Pool.instance << { :id => 1, :data => proc { sleep 0.4 } }
      id2 = Callisto::Pool.instance << { :id => 2, :data => proc { sleep 0.4 } }
      sleep 0.1
      Callisto::Pool.instance.pending.must_equal([id2])
      Callisto::Pool.instance.wait(id1)
      Callisto::Pool.instance.running.must_equal([id2])
      Callisto::Pool.instance.wait(id2)
      Callisto::Pool.instance.running.must_equal([])
    end

  end

end
