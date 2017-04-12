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

		updates = @record_enumerator.each do |record, offset|
			@table.mark(record, offset, @transaction_id)
		
            new_record = Record.copy @transaction_id, record
			new_record.set @set_clause
			tmp_tbl.insert new_record
		end		

		@table.concat tmp_tbl
		@db.drop_table table_name

		@table.cleanup
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
