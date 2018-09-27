require_relative 'test_helper'

describe Adrian::Queue do
  class TestQueue < Adrian::Queue
    attr_accessor :item

    def pop_item
      @item
    end

    def push_item(item)
      @item = item
    end
  end

  describe 'when a max age is defined' do
    let(:queue) { TestQueue.new(max_age: 60) }

    it 'validates the age of items' do
      item = Adrian::QueueItem.new('value', Time.now)
      queue.push(item)
      queue.pop.must_equal item

      item = Adrian::QueueItem.new('value', Time.now - 120)
      queue.push(item)
      lambda { queue.pop }.must_raise(Adrian::Queue::ItemTooOldError)
    end
  end

  it 'sets the queue on the items' do
    q = TestQueue.new

    item = Adrian::QueueItem.new('value', Time.now)

    item.queue.must_be_nil

    q.push(item)

    item.queue.must_be_nil

    popped_item = q.pop

    popped_item.must_equal item
    item.queue.must_equal q
  end

  describe '#last_retry?' do
    describe 'when max_age and interval are defined' do
      describe 'age is within the last interval/delay' do
        let(:item) { Adrian::QueueItem.new('value', Time.now - 51) }
        it { assert TestQueue.new(max_age: 60, delay: 10).last_retry?(item) }
      end

      describe 'age is at the beginning of the last interval/delay' do
        let(:item) { Adrian::QueueItem.new('value', Time.now - 50) }
        it { assert TestQueue.new(max_age: 60, delay: 10).last_retry?(item) }
      end

      describe 'age is after last interval/delay (item queued longer than the delay)' do
        let(:item) { Adrian::QueueItem.new('value', Time.now - 61) }
        it { assert TestQueue.new(max_age: 60, delay: 10).last_retry?(item) }
      end

      describe 'age is not within the last interval/delay' do
        let(:item) { Adrian::QueueItem.new('value', Time.now - 49) }
        it { refute TestQueue.new(max_age: 60, delay: 10).last_retry?(item) }
      end
    end

    describe 'when either max_age and delay are not defined' do
      let(:item) { Adrian::QueueItem.new('value', Time.now) }
      it { refute TestQueue.new(max_age: 60).last_retry?(item) }
      it { refute TestQueue.new(delay: 10).last_retry?(item) }
    end
  end
end
