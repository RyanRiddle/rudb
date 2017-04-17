require_relative 'result'

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

        Result.new(
            Proc.new {},
            Proc.new { "1 new row" }
        )
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        yield "INSERT #{@hash}"
    end
end
