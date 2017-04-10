class UpdateCommand
    attr_reader :table

    def initialize(record_enumerator, table, set_clause, db)
        @record_enumerator = record_enumerator
        @table = table
        @set_clause = set_clause
        @db = db
    end

    def execute(transaction_id)
		tmp_tbl = @db.create_table("tmp_tbl")

		updates = @record_enumerator.each do |record, offset|
			@table.mark(offset, transaction_id)
		
			record.set(@set_clause)
			tmp_tbl.insert(record, transaction_id)
		end		

		@table.concat tmp_tbl
		@db.drop_table ("tmp_tbl")

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
