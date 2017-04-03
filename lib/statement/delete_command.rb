class DeleteCommand
    attr_reader :table

    def initialize(record_enumerator, table)
        @record_enumerator = record_enumerator
        @table = table
    end

    def execute
        @record_enumerator.each do |record, offset|
            @table.mark offset
        end

        @table.cleanup
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
