require 'adrian/queue'
require 'fileutils'

module Adrian
  class DirectoryQueue < Adrian::Queue
    include Filters

    def self.create(options = {})
      queue = new(options)
      FileUtils.mkdir_p(queue.available_path)
      FileUtils.mkdir_p(queue.reserved_path)
      queue
    end

    attr_reader :available_path, :reserved_path, :logger

    # Note:
    # There is the possibility of an item being consumed by multiple processes when its still in the queue after its lock expires.
    # The reason for allowing this is:
    #   1. It's much simpler than introducing a seperate monitoring process to handle lock expiry.
    #   2. This is an acceptable and rare event. e.g. it only happens when the process working on the item crashes without being able to release the lock
    def initialize(options = {})
      super
      @available_path = options.fetch(:path)
      @reserved_path  = options.fetch(:reserved_path, default_reserved_path)
      @logger         = options[:logger]
      filters << Filters::FileLock.new(:duration => options[:lock_duration], :reserved_path => reserved_path)
      filters << Filters::Delay.new(:duration => options[:delay]) if options[:delay]
    end

    def pop_item
      while item = items.shift
        return item if reserve(item)
      end
      nil
    end

    def push_item(value)
      item = wrap_item(value)
      item.move(available_path)
      item.touch
      self
    end

    def length
      available_files.count { |file| File.file?(file) }
    end

    def include?(value)
      item = wrap_item(value)
      items.include?(item)
    end

    def items_length
      @items ? @items.length : 0
    end

    protected

    def wrap_item(value)
      item = value.is_a?(FileItem) ? value : FileItem.new(value)
      item.logger ||= logger
      item
    end

    def reserve(item)
      item.move(reserved_path)
      item.touch
      true
    rescue Errno::ENOENT => e
      false
    end

    def items
      return @items if @items && @items.length > 0
      @items = begin
        items = files.map { |file| wrap_item(file) }
        items.reject! { |item| !item.exist? || filter?(item) }
        items.sort_by(&:updated_at)
      end
    end

    def files
      (available_files + reserved_files).select { |file| File.file?(file) }
    end

    def available_files
      Dir.glob("#{available_path}/*")
    end

    def reserved_files
      Dir.glob("#{reserved_path}/*")
    end

    def default_reserved_path
      File.join(@available_path, 'cur')
    end

  end
end
