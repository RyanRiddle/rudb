class InsertCommand
    attr_reader :table

    def initialize(table, hash)
        @table = table
        @hash = hash
    end

    def execute
        @table.insert(@hash)
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        yield "INSERT #{@hash}"
    end
end
