class UpdateCommand
    def initialize(record_enumerator, table, set_clause)
        @record_enumerator = record_enumerator
        @table = table
        @set_clause = set_clause
    end

    def execute
		tmp_tbl = @db.create_table("tmp_tbl")

		updates = @record_enumerator.each do |record, offset|
			@table.mark(offset)
		
			record.set(@set_clause)
			tmp_tbl.insert record
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
