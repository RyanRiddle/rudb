require 'pry'

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

		condition_variables = (@record_enumerator.map do |record, offset|
			cv = @table.mark(record, offset, @transaction_id)
		
            new_record = Record.copy @transaction_id, record
			new_record.set @set_clause
			tmp_tbl.insert new_record
			#@table.insert new_record

            cv
		end).force

		@table.concat tmp_tbl
		@db.drop_table table_name

		#@table.cleanup

        Result.new(
            Proc.new { condition_variables.each { |cv| cv.signal } },
            Proc.new { "Updated #{condition_variables.count} rows" }
        )
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
