require_relative 'query'
require_relative 'record'

class Table
	attr_reader :filename	# used to copy from one table to another

	def initialize(name, dir, db)
		@db = db
		@name = name
		@filename = File.join(dir, "#{@name}.db")
		f = File.open @filename, "w"
		f.close
	end

	def destroy
		File.delete @filename
	end
	
	def concat(other_tbl)
		File.open(@filename, "a") do |f|
			File.copy_stream(other_tbl.filename, f)
		end	
	end

	def insert(row)
		# This code smells
		if row.class == Record
			record = row
		else
			record = Record.new row
		end

		write record
	end
	
	def write(record)
		File.open(@filename, "a") do |f|
			serialized_record = record.serialize
			header = "0 #{serialized_record.length}"
			f.puts header
			f.write serialized_record
		end
	end

	def mark(offset)	# marks record for deletion
		File.write(@filename, "1", offset)
	end

	def query
		Query.new @filename, self, @db
	end
end
