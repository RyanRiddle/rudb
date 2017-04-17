require_relative 'result'

class DeleteCommand
    attr_reader :table

    def initialize(record_enumerator, table, transaction_id)
        @record_enumerator = record_enumerator
        @table = table
        @transaction_id = transaction_id
    end

    def execute
        condition_variables = (@record_enumerator.map do |record, offset|
            @table.mark(record, offset, @transaction_id)
        end).force

        Result.new(
            Proc.new { condition_variables.each { |cv| cv.signal } },
            Proc.new { "Deleted #{condition_variables.count} rows" }
        )

        #@table.cleanup
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        @record_enumerator.each do |record, offset|
            yield "DELETE #{offset}"
        end
    end
end
