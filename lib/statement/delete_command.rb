require_relative 'result'
require 'pry'

class LazyRecord
    def new(&code)
        code.call
    end
end

class DeleteCommand
    attr_reader :table

    def initialize(record_enumerator, table, transaction_id)
        @record_enumerator = record_enumerator
        @table = table
        @transaction_id = transaction_id
    end

    def execute
        ms_and_cvs = {}
        begin
            while true
                _, offset = @record_enumerator.next
                result = @table.mark(offset, @transaction_id)
                if result == TOO_LATE
                    break FailedStatement.new "ya got beat", ms_and_cvs
                else
                    m_and_cv = @table.get_mutex_and_condition_variable offset
                    ms_and_cvs.merge! m_and_cv
                end 
            end
        rescue StopIteration
            SuccessfulStatement.new "deleted #{ms_and_cvs.count} rows", ms_and_cvs
        end

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
