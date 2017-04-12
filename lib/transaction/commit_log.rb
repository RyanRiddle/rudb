class INVALID
end

class IN_PROGRESS
end

class COMMITTED
end

class ABORTED
end

class CommitLog
    def initialize
        @transaction_statuses = []
        @transaction_statuses[0] = INVALID
        @active_window = [0, 0]
    end

    def in_progress? transaction_id
        status(transaction_id) == IN_PROGRESS
    end

    def committed? transaction_id
        status(transaction_id) == COMMITTED
    end

    def aborted? transaction_id
        status(transaction_id) == ABORTED
    end

    def invalid? transaction_id
        status(transaction_id) == INVALID
    end

    def start transaction_id
        @transaction_statuses[transaction_id] = IN_PROGRESS
    end

    def commit transaction_id
        @transaction_statuses[transaction_id] = COMMITTED
    end

    def abort transaction_id
        @transaction_statuses[transaction_id] = ABORTED
    end

    private
    def status transaction_id
        @transaction_statuses[transaction_id]
    end
end
