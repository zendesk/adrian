require_relative 'test_helper'
require 'tempfile'

describe Adrian::FileItem do
  before do
    @item = Adrian::FileItem.new(Tempfile.new('file_item_test').path)
  end

  it 'aliases value as path' do
    item = Adrian::FileItem.new('path/a')
    assert_equal 'path/a', item.value
  end

  it 'has a name from the path' do
    item = Adrian::FileItem.new('path/name.ext')
    assert_equal 'name.ext', item.name
  end

  it 'is equal to another item when they have the same name' do
    item1 = Adrian::FileItem.new('path/a')
    item2 = Adrian::FileItem.new('path/b')
    assert(item1 != item2)

    item3 = Adrian::FileItem.new('path/a')
    assert_equal item1, item3
  end

  describe 'updated_at' do

    it 'is the atime of the file' do
      _(@item.updated_at).must_equal(File.atime(@item.path))
    end

    it 'is nil when moved by another process' do
      item = Adrian::FileItem.new('moved/during/initialize')
      assert_equal false, item.exist?
      assert_nil(item.updated_at)
    end

    it 'is cached' do
      updated_at = @item.updated_at
      assert @item.updated_at
      File.unlink(@item.path)
      assert_equal false, @item.exist?

      assert_equal updated_at, @item.updated_at
    end

  end

  describe 'created_at' do

    it 'is the mtime of the file' do
      _(@item.created_at).must_equal(File.mtime(@item.path))
    end

    it 'is nil when moved by another process' do
      item = Adrian::FileItem.new('moved/during/initialize')
      assert_equal false, item.exist?
      assert_nil(item.created_at)
    end

    it 'is cached' do
      created_at = @item.created_at
      assert @item.created_at
      File.unlink(@item.path)
      assert_equal false, @item.exist?

      assert_equal created_at, @item.created_at
    end

  end

  describe 'move' do
    before do
      @destination = Dir.mktmpdir('file_item_move_test')
    end

    it 'moves the file to the given directory' do
      @item.move(@destination)
      assert_equal true, File.exist?(File.join(@destination, @item.name))
    end

    it 'updates the path to its new location' do
      @item.move(@destination)
      assert_equal @destination, File.dirname(@item.path)
    end

    it 'logs the move on the logger' do
      destination_file_name = File.join(@destination, File.basename(@item.path))
      logger = MiniTest::Mock.new
      logger.expect(:info, nil, ["Moving #{@item.path} to #{destination_file_name}"])
      @item.logger = logger

      @item.move(@destination)

      logger.verify
    end

    it 'does not change the atime' do
      atime = File.atime(@item.path)
      @item.move(@destination)
      _(File.atime(@item.path)).must_equal(atime)
    end

    it 'does not change the mtime' do
      mtime = File.mtime(@item.path)
      @item.move(@destination)
      _(File.mtime(@item.path)).must_equal(mtime)
    end

  end

  describe 'touch' do

    it 'changes the update timestamp to the current time' do
      now = Time.now - 100
      Time.stub(:now, now) { @item.touch }

      assert_equal now.to_i, @item.updated_at.to_i
    end

    it 'changes the atime' do
      atime = File.atime(@item.path).to_i

      now = (Time.now - 100)
      Time.stub(:now, now) { @item.touch }

      _(now.to_i).wont_equal(atime)
      _(File.atime(@item.path).to_i).must_equal(now.to_i)
    end

    it 'does not change the mtime' do
      mtime = File.mtime(@item.path).to_i

      now = (Time.now - 100)
      Time.stub(:new, now) { @item.touch }

      _(now.to_i).wont_equal(mtime)
      _(File.mtime(@item.path).to_i).must_equal(mtime)
    end

  end

  it 'exists when the file at the given path exists' do
    assert_equal true, @item.exist?
    File.unlink(@item.path)

    assert_equal false, @item.exist?
  end

end
