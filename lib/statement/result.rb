class Result
    def initialize(cleanup_code, peek_code)
        @cleanup_code = cleanup_code
        @peek_code = peek_code
    end

    def peek
        @peek_code.call
    end

    def commit
        @cleanup_code.call
        @peek_code.call
    end
end
