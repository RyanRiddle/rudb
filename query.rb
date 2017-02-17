require_relative 'database' # for Record

class Query
	def initialize(filename)
		@enum = Enumerator.new do |y|
			File.open(filename, "r") do |f|
				until f.eof?
					serialized_record = f.readline
					record = Record::read serialized_record
					y << record
				end
			end
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
		add = clause.all? do |col, value|
			index = retrieve_column_index col
			record.matches?(index, value)
		end

		if add
			results.push(record)
		end
	end

	def select
	end
end
