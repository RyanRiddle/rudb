class INVALID
end

class IN_PROGRESS
    def self.do_the_needful actives, id
        actives.push id 
    end 
end

class COMMITTED
    def self.do_the_needful actives, id
        actives.delete id
    end
end

class ABORTED
    def self.do_the_needful actives, id
        actives.delete id
    end
end

class CommitLog
    def initialize filename
        @filename = filename

        if File.exists? @filename
            @transaction_statuses, _ = read
            @active_transactions = []
        else
            @transaction_statuses = [INVALID]
            @active_transactions = []
        end

        @file_mutex = Mutex.new
    end

    def last_assigned_id
        @transaction_statuses.length - 1
    end

    def in_progress? transaction_id
        get_status(transaction_id) == IN_PROGRESS
    end

    def committed? transaction_id
        get_status(transaction_id) == COMMITTED
    end

    def aborted? transaction_id
        get_status(transaction_id) == ABORTED
    end

    def invalid? transaction_id
        get_status(transaction_id) == INVALID
    end

    def start transaction_id
        # returns a list of active transaction ids
        return set_status transaction_id, IN_PROGRESS
    end

    def commit transaction_id
        set_status transaction_id, COMMITTED
    end

    def abort transaction_id
        set_status transaction_id, ABORTED
    end

    private
    def get_status transaction_id
        @transaction_statuses[transaction_id]
    end

    def set_status transaction_id, status
        result = nil
        @file_mutex.synchronize do
            @transaction_statuses[transaction_id] = status
            status.do_the_needful @active_transactions, transaction_id
            result = Array.new @active_transactions
            write()
        end
        return result
    end

    def read
        Marshal.load(File.read(@filename))
    end

    def write
        data = Marshal.dump [@transaction_statuses, @active_transactions]
        File.write(@filename, data)
    end
end
