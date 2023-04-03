require_relative 'test_helper'

describe Adrian::ArrayQueue do
  it 'should allow construction with an array' do
    q = Adrian::ArrayQueue.new([1,2,3])
    _(q.pop.value).must_equal 1
    _(q.pop.value).must_equal 2
    _(q.pop.value).must_equal 3
    _(q.pop).must_be_nil
  end

  it 'should allow construction without an array' do
    q = Adrian::ArrayQueue.new
    _(q.pop).must_be_nil
  end

  it 'should act as a queue' do
    q = Adrian::ArrayQueue.new

    q.push(1)
    q.push(2)
    q.push(3)

    _(q.length).must_equal 3

    _(q.pop.value).must_equal 1
    _(q.pop.value).must_equal 2
    _(q.pop.value).must_equal 3
    _(q.pop).must_be_nil

    _(q.length).must_equal 0
  end
end
