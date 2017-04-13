require_relative '../util/transaction_id'

class IdGenerator
    def initialize last_id
        @next_id = last_id + 1
    end

    def next
        # do this because Enumerators are not thread safe

        if @next_id > MAX_TRANSACTION_ID
            raise "Out of transaction ids"
        end
        
        @next_id += 1 
        @next_id - 1
    end
end
