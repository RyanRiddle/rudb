require_relative '../util/transaction_id'

class IdGenerator
    def initialize
        @range = (1..MAX_TRANSACTION_ID).each
    end

    def next
        @range.next
    end
end
