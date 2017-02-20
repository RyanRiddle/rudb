require_relative 'query'
require_relative 'record'

class Table
	def initialize(name, dir)
		@name = name
		@filename = File.join(dir, "#{@name}.db")
	end

	def insert(row)
		record = Record.new row
		write record
	end
	
	def write(record)
		File.open(@filename, "a") do |f|
			serialized_record = record.serialize
			f.write(serialized_record.length.to_s + "\n")
			f.write(serialized_record)
		end
	end

	def query
		Query.new @filename, self
	end
end
