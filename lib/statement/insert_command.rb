class InsertCommand
    attr_reader :table

    def initialize(table, hash, transaction_id)
        @table = table
        @hash = hash
        @transaction_id = transaction_id
    end

    def execute
        @table.insert(@hash, @transaction_id)
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        yield "INSERT #{@hash}"
    end
end
