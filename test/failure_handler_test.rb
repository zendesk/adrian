require_relative 'test_helper'

require 'adrian/failure_handler'

describe Adrian::FailureHandler do
  before do
    @handler = Adrian::FailureHandler.new

    $failure = nil

    @handler.add_rule(RuntimeError)  { :runtime  }
    @handler.add_rule(StandardError) { :standard }
  end

  it "should match rules in the order they were added" do
    block = @handler.handle(RuntimeError.new)
    assert block
    _(block.call).must_equal :runtime

    block = @handler.handle(StandardError.new)
    assert block
    _(block.call).must_equal :standard
  end

  it "should do nothing when no rules match" do
    _(@handler.handle(Exception.new)).must_be_nil
  end

  describe "the success rule" do
    before do
      @handler = Adrian::FailureHandler.new
      @handler.add_rule(nil) { :success  }
    end

    it "should match when there is no exception" do
      _(@handler.handle(RuntimeError.new)).must_be_nil

      block = @handler.handle(nil)
      assert block
      _(block.call).must_equal :success
    end
  end

end
