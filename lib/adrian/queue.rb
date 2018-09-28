module Adrian
  class Queue
    class ItemTooOldError < RuntimeError
      attr_reader :item, :queue

      def initialize(item, queue)
        super()
        @item  = item
        @queue = queue
      end
    end

    def initialize(options = {})
      @options = options
    end

    def pop
      item = pop_item
      item.queue = self if item
      verify_age!(item)
    end

    def push(item)
      push_item(item)
    end

    def verify_age!(item)
      if item && max_age && item.age > max_age
        raise ItemTooOldError.new(item, self)
      end

      item
    end

    def max_age
      @max_age ||= @options[:max_age]
    end

    def last_retry?(item)
      item && max_age && delay && item.age >= (max_age - delay)
    end

    def delay
      @delay ||= @options[:delay]
    end

    def pop_item
      raise "#{self.class.name}#pop_item is not defined"
    end

    def push_item(item)
      raise "#{self.class.name}#push_item is not defined"
    end

    def length
      raise "#{self.class.name}#length is not defined"
    end
  end
end
