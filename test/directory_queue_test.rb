require_relative 'test_helper'
require 'tempfile'
require 'tmpdir'

describe Adrian::DirectoryQueue do
  before do
    @q = Adrian::DirectoryQueue.create(:available_path => Dir.mktmpdir('dir_queue_test'))
  end

  it 'should act as a queue for files' do
    item1 = Tempfile.new('item1-').path
    item2 = Tempfile.new('item2-').path
    item3 = Tempfile.new('item3-').path

    @q.push(item1)
    @q.push(item2)
    @q.push(item3)

    @q.pop.must_equal Adrian::FileItem.new(item1)
    @q.pop.must_equal Adrian::FileItem.new(item2)
    @q.pop.must_equal Adrian::FileItem.new(item3)
    @q.pop.must_be_nil
  end

  describe 'file backend' do

    describe 'pop' do
      before do
        @item = Adrian::FileItem.new(Tempfile.new('item').path)
      end

      it 'provides an available file' do
        @q.push(@item)
        assert_equal @item, @q.pop
      end

      it 'moves the file to the reserved directory' do
        @q.push(@item)
        original_path = @item.path
        item = @q.pop
        assert_equal @item, item

        assert_equal false, File.exist?(original_path)
        assert_equal true,  File.exist?(File.join(@q.reserved_path, @item.name))
      end

      it 'touches the item' do
        @q.push(@item)
        now  = Time.new - 100
        item = nil
        Time.stub(:new, now) { item = @q.pop }

        assert_equal now.to_i, item.updated_at.to_i
      end

      it 'skips the file when moved by another process' do
        def @q.files
          [ 'no/longer/exists' ]
        end
        assert_equal nil, @q.pop
      end

      it "only provides normal files" do
        not_file = Dir.mktmpdir(@q.available_path, 'directory_queue_x')
        assert_equal nil, @q.pop
      end

    end

    describe 'push' do
      before do
        @item = Adrian::FileItem.new(Tempfile.new('item').path)
      end

      it 'moves the file to the available directory' do
        original_path = @item.path
        @q.push(@item)

        assert_equal false, File.exist?(original_path)
        assert_equal true,  File.exist?(File.join(@q.available_path, @item.name))
      end

      it 'touches the item' do
        now = Time.new - 100
        Time.stub(:new, now) { @q.push(@item) }

        assert_equal now.to_i, @item.updated_at.to_i
      end

    end

  end

end