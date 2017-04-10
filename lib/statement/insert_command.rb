class InsertCommand
    attr_reader :table

    def initialize(table, hash)
        @table = table
        @hash = hash
    end

    def execute(transaction_id)
        @table.insert(@hash, transaction_id)
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        yield "INSERT #{@hash}"
    end
end
