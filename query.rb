require_relative 'database' # for Record

class Query
	def initialize(filename, table, enum=nil)
		@table = table
		@enum = if enum.nil?
			Enumerator.new do |y|
				File.open(filename, "r") do |f|
					until f.eof?
						serialized_record = f.readline
						record = Record::read serialized_record
						y << record
					end
				end
			end
		else
			enum
		end
	end

	def top(num)
		num.times.map do
			begin
				@enum.next
			rescue StopIteration
				next
			end
		end
	end

	def where(clause = {})
		e = Enumerator.new do |y|
			while true
				begin
					record = @enum.next
					all = clause.all? do |col, value|
							index = @table.retrieve_column_index col
							record.matches?(index, value)
					end
					if all
						y << record
					end
				rescue StopIteration
					raise StopIteration
				end
			end
		end

		Query.new @filename, @table, e
	end

	def select(*cols)
		e = Enumerator.new do |y|
			while true
				begin
					record = @enum.next

					if not cols.empty?
						col_indices = cols.map do |col| 
							@table.retrieve_column_index col
						end
						record = record.choose_columns *col_indices
					end

					y << record
				rescue StopIteration
					raise StopIteration
				end
			end
		end

		Query.new @filename, @table, e
	end
end
