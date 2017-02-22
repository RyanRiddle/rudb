require_relative 'record'

class Query
	def initialize(table, db)
		@table = table
		@db = db

		@record_enumerator = table.each_record.lazy
	end

	def top(num=nil)
		if num.nil?
			return @record_enumerator.force()
		end

		@record_enumerator.take(num).force()
	end

	def update(clause = {})
		tmp_tbl = @db.create_table("tmp_tbl")

		updates = @record_enumerator.each do |record, offset|
			@table.mark(offset)
		
			record.set(clause)
			tmp_tbl.insert record
		end		

		@table.concat tmp_tbl
		@db.drop_table ("tmp_tbl")

		@table.cleanup
	end

	def delete
		@record_enumerator.each do |record, offset|
			@table.mark offset
		end

		#@table.cleanup
	end

	def where(clause = {})
		@record_enumerator = @record_enumerator.select do |record, offset|
			clause.all? do |key, value|
				record.matches?(key, value)
			end
		end
		self
	end

	def select(*cols)
		@record_enumerator = @record_enumerator.map do |record, offset|
			record.values_at *cols
		end
		self		
	end
end
