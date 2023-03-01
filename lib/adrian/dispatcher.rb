require 'adrian/failure_handler'

module Adrian
  class Dispatcher
    attr_reader :running

    def initialize(options = {})
      @failure_handler     = FailureHandler.new
      @stop_when_done      = !!options[:stop_when_done]
      @stop_when_signalled = options.fetch(:stop_when_signalled, true)
      @sleep               = options[:sleep] || 0.5
      @options             = options
    end

    def on_failure(*exceptions)
      @failure_handler.add_rule(*exceptions, block)
    end

    def on_done
      @failure_handler.add_rule(nil, block)
    end

    def start(queue, worker_class)
      trap_stop_signals if @stop_when_signalled
      @running = true

      while @running do
        begin
          item = queue.pop
        rescue Adrian::Queue::ItemTooOldError => e
          if handler = @failure_handler.handle(e)
            handler.call(e.item, nil, e)
          end
          item = nil
          next
        end

        if item
          delegate_work(item, worker_class)
        else
          if @stop_when_done
            stop
          else
            sleep(@sleep) if @sleep
          end
        end
      end
    end

    def stop
      @running = false
    end

    def trap_stop_signals
      Signal.trap('TERM') { stop }
      Signal.trap('INT')  { stop }
    end

    def delegate_work(item, worker_class)
      worker = worker_class.new(item)
      worker.report_to(self)
      worker.perform
    end

    def work_done(item, worker, exception = nil)
      if handler = @failure_handler.handle(exception)
        handler.call(item, worker, exception)
      else
        raise exception if exception
      end
    end

  end
end
