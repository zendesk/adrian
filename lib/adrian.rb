require 'adrian/version'

module Adrian
  autoload :ArrayQueue,             'adrian/array_queue'
  autoload :CompositeQueue,         'adrian/composite_queue'
  autoload :DirectoryQueue,         'adrian/directory_queue'
  autoload :RotatingDirectoryQueue, 'adrian/rotating_directory_queue'
  autoload :Dispatcher,             'adrian/dispatcher'
  autoload :FileItem,               'adrian/file_item'
  autoload :Filters,                'adrian/filters'
  autoload :GirlFridayDispatcher,   'adrian/girl_friday_dispatcher'
  autoload :Queue,                  'adrian/queue'
  autoload :QueueItem,              'adrian/queue_item'
  autoload :Worker,                 'adrian/worker'
end
