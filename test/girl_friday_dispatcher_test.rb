require_relative 'test_helper'

describe Adrian::GirlFridayDispatcher do
  before do
    $done_items = []
    @q = Adrian::ArrayQueue.new
    @dispatcher = Adrian::GirlFridayDispatcher.new(:stop_when_done => true)
  end

  describe "work delegation" do
    it "should instantiate an instance of the worker for each item and ask it to perform" do
      worker = Class.new(Adrian::Worker) do
        def work
          sleep(rand)
          $done_items << @item.value
        end
      end

      @q.push(1)
      @q.push(2)
      @q.push(3)

      @dispatcher.start(@q, worker)

      _($done_items.sort).must_equal([1, 2, 3])
    end
  end
end
