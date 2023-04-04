require_relative 'test_helper'

describe Adrian::Dispatcher do
  before do
    $done_items = []
    @q          = Adrian::ArrayQueue.new([], :max_age => 1000)
    @dispatcher = Adrian::Dispatcher.new(:stop_when_done => true)
    @worker     = TestWorker
  end

  class TestWorker

    def initialize(item)
      @item       = item
      @done_items = []
    end

    def perform
      $done_items << @item.value
    end

    def report_to(boss)
      @boss = boss
    end

  end

  describe "work delegation" do
    it "should instantiate an instance of the worker for each item and ask it to perform" do
      @q.push(1)
      @q.push(2)
      @q.push(3)

      @dispatcher.start(@q, @worker)

      _($done_items).must_equal([1, 2, 3])
    end
  end

  describe "a queue with old items" do
    before do
      @q.push(Adrian::QueueItem.new(1, Time.now))
      @old_item = Adrian::QueueItem.new(2, Time.now - 2000)
      @q.push(@old_item)
      @q.push(Adrian::QueueItem.new(3, Time.now))
    end

    it 'skips the old items' do
      @dispatcher.start(@q, @worker)

      _($done_items).must_equal([1, 3])
    end

    it 'calls the handler for Adrian::Queue::ItemTooOldError' do
      handled_items      = []
      handled_exceptions = []

      @dispatcher.on_failure(Adrian::Queue::ItemTooOldError) do |item, worker, exception|
        handled_items      << item
        handled_exceptions << exception
      end

      @dispatcher.start(@q, @worker)

      _(handled_items).must_equal [@old_item]
      _(handled_exceptions.size).must_equal 1
      _(handled_exceptions.first).must_be_instance_of Adrian::Queue::ItemTooOldError
    end
  end

  describe "work evaluation" do

    it "stops when receiving a termination signal" do
      @dispatcher = Adrian::Dispatcher.new(:stop_when_done => false)
      dispatch_thread = Thread.new { @dispatcher.start(@q, @worker) }
      sleep(0.1)
      assert_equal true, @dispatcher.running

      Process.kill('TERM', Process.pid)
      assert_equal false, @dispatcher.running
      dispatch_thread.exit
    end

    it "should use the failure handler to handle the result" do
      @dispatcher.on_failure(RuntimeError) do |item, worker, exception|
        @q.push(item)
      end

      @dispatcher.work_done(1, nil)
      _(@q.pop).must_be_nil

      @dispatcher.work_done(1, nil, nil)
      _(@q.pop).must_be_nil

      @dispatcher.work_done(1, nil, RuntimeError.new)
      _(@q.pop.value).must_equal 1
    end
  end
end
