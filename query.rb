require_relative 'database' # for Record

class Query
	def initialize(filename, table, enum=nil)
		@filename = filename
		@table = table

		@record_enumerator = enum || 
			Enumerator.new do |y|
				File.open(filename, "r") do |f|
					until f.eof?
						serialized_record = f.readline
						record = Record::read serialized_record
						y << record
					end
				end
			end.lazy
	end

	def top(num)
		@record_enumerator.take(num).force()
	end

	def where(clause = {})
		e = @record_enumerator.select do |record|
			clause.all? do |col, value|
				index = @table.retrieve_column_index col
				record.matches?(index, value)
			end
		end

		Query.new @filename, @table, e
	end

	def select(*cols)
		e = @record_enumerator.map do |record|
			if not cols.empty?
				col_indices = cols.map do |col| 
					@table.retrieve_column_index col
				end
				record.choose_columns *col_indices
			else
				record
			end
		end
			
		Query.new @filename, @table, e
	end
end
