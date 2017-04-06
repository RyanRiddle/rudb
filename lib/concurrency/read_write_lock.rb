class ReadWriteLock
    # Gives priority to readers

    class MutexToReadManager
        def initialize
            @mutex_read_manager_map = {}
        end

        def get_read_manager mutex
            if @mutex_read_manager_map[mutex].nil?
                @mutex_read_manager_map[mutex] = ReadManager.new
            end

            @mutex_read_manager_map[mutex]
        end
    end

    class ReadManager

        def initialize
            @num_blocking_readers = 0
            @reader_mutex = Mutex.new
        end

        attr_accessor :num_blocking_readers

        def begin_read mutex
            @reader_mutex.synchronize do
                increment_num_blocking_readers
                if one_blocking_reader?
                    mutex.lock
                end
            end
        end

        def end_read mutex
            @reader_mutex.synchronize do
                decrement_num_blocking_readers
                if no_blocking_readers?
                    mutex.unlock
                end
            end
        end

        private
        def increment_num_blocking_readers
            @num_blocking_readers += 1
        end

        def decrement_num_blocking_readers
            @num_blocking_readers -= 1
        end

        def one_blocking_reader?
            @num_blocking_readers == 1
        end

        def no_blocking_readers?
            @num_blocking_readers == 0
        end
    end

    @@mutex_to_read_manager = MutexToReadManager.new

    def self.read(mutex, &proc)
        read_manager = get_read_manager mutex
        read_manager.begin_read mutex
        proc.call
        read_manager.end_read mutex    
    end

    def self.write(mutex, &proc)
        mutex.synchronize do
            proc.call
        end
    end

    def self.num_blocking_readers mutex
        (get_read_manager mutex).num_blocking_readers
    end

    private
    def self.get_read_manager mutex
        @@mutex_to_read_manager.get_read_manager mutex
    end
end
