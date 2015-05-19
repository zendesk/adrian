module Adrian
  class FileItem < QueueItem
    attr_accessor :logger

    def initialize(value)
      @value = value
      created_at
      updated_at
    end

    def path
      value
    end

    def name
      File.basename(path)
    end

    def ==(other)
      other.respond_to?(:name) &&
        name == other.name
    end

    def move(destination)
      destination_path = File.join(destination, File.basename(path))
      logger.info("Moving #{path} to #{destination_path}") if logger
      File.rename(path, destination_path)
      @value = destination_path
    end

    def stat
      @stat = File.stat(path)
    rescue Errno::ENOENT
      @stat = nil
    end

    def atime
      stat ? stat.atime.utc : nil
    end

    def mtime
      stat ? stat.mtime.utc : nil
    end

    def updated_at
      @updated_at ||= atime
    end

    def created_at
      @created_at ||= mtime
    end

    def touch(updated_at = Time.now)
      @updated_at = updated_at.utc
      File.utime(updated_at, created_at, path)
    end

    def exist?
      File.exist?(path)
    end

  end
end
