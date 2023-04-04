require_relative 'test_helper'

describe "Adrian::Dispatcher lifecycle" do
  class Worker < Adrian::Worker
    def work
      $done_items << item.value
    end
  end

  before do
    $done_items = []
    @q = Adrian::ArrayQueue.new([1,2,3])
  end

  describe "stop_when_done" do
    describe "set to true" do
      before do
        @dispatcher = Adrian::Dispatcher.new(:stop_when_done => true)
      end

      it "should have all the work done and stop" do
        t = Thread.new do
          @dispatcher.start(@q, Worker)
        end

        sleep(0.5)

        _(@q.pop).must_be_nil

        _($done_items).must_equal([1,2,3])

        _(@dispatcher.running).must_equal false
      end
    end

    describe "set to false" do
      before do
        @dispatcher = Adrian::Dispatcher.new(:stop_when_done => false)
      end

      it "should have all the work done and continue" do
        t = Thread.new do
          @dispatcher.start(@q, Worker)
        end

        sleep(0.5)

        _(@q.pop).must_be_nil

        _($done_items).must_equal([1,2,3])

        _(@dispatcher.running).must_equal true
        t.kill
      end
    end
  end

  describe "#stop" do
    before do
      @dispatcher = Adrian::Dispatcher.new(:sleep => 0.1)
    end

    it "should stop a running dispatcher" do
      t = Thread.new do
        @dispatcher.start(@q, Worker)
      end

      sleep(0.5)

      _(@dispatcher.running).must_equal true
      _(t.status).wont_equal false

      @dispatcher.stop

      sleep(0.5)

      _(@dispatcher.running).must_equal false
      _(t.status).must_equal false
    end
  end

end
