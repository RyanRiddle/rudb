require 'pry'
require_relative 'result'

class UpdateCommand
    attr_reader :table

    def initialize(record_enumerator, table, set_clause, db, transaction_id)
        @record_enumerator = record_enumerator
        @table = table
        @set_clause = set_clause
        @db = db
        @transaction_id = transaction_id
    end

    def execute
        table_name = "#{@transaction_id}_tmp_tbl" 
		tmp_tbl = @db.create_table table_name

        ms_and_cvs = {}
        result = begin
            while true
                _, offset = @record_enumerator.next
                result = @table.mark(offset, @transaction_id)
                if result == TOO_LATE
                    break FailedStatement.new "ya got beat", ms_and_cvs
                else
                    m_and_cv = @table.get_mutex_and_condition_variable offset
                    ms_and_cvs.merge! m_and_cv

                    # consider making record enumerator
                    # return a function that gets the record when you
                    # are ready
                    record = @table.get_record_at offset
                    new_record = Record.copy @transaction_id, record
                    new_record.set @set_clause
                    tmp_tbl.insert new_record
                end 
            end
        rescue StopIteration
            SuccessfulStatement.new "updated #{ms_and_cvs.count} rows", ms_and_cvs
        end

		@table.concat tmp_tbl
		@db.drop_table table_name

		#@table.cleanup
        return result
    end

    def render
        if not block_given?
            raise "this method takes a block"
        end

        @record_enumerator.each do |record, offset|
            record.set(@set_clause)
            yield "UPDATE #{offset} #{record}"
        end
    end
end
