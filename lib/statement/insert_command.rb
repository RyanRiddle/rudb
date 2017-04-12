class InsertCommand
    attr_reader :table

    def initialize(table, hash, transaction_id)
        @table = table
        @hash = hash
        @transaction_id = transaction_id
    end

    def execute
        record = Record.new @transaction_id, @hash
        @table.insert record
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        yield "INSERT #{@hash}"
    end
end
