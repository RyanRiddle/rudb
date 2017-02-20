require_relative 'database' # for Record

class Query
	def initialize(filename, table)
		@filename = filename
		@table = table

		@record_enumerator =
			Enumerator.new do |y|
				File.open(filename, "r") do |f|
					until f.eof?
						length = f.readline.to_i
						serialized_record = f.read length
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
		@record_enumerator = @record_enumerator.select do |record|
			clause.all? do |key, value|
				record.matches?(key, value)
			end
		end
		self
	end

	def select(*cols)
		@reocrd_enumerator = @record_enumerator.map do |record|
			record.values_at *cols
		end
		self		
	end
end
