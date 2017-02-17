require_relative 'query'

class Record
	def initialize(attrs)
		@attrs = attrs
	end

	def write
		Marshal.dump @attrs
	end

	def self.read(marshaled_record)
		Record.new (Marshal.load marshaled_record)
	end

	def matches?(index, value)
		@attrs[index] == value
	end

	def choose_columns(*col_indices)
		@attrs.values_at(*col_indices)
	end
end

class Table
	def initialize(name, *columns)
		@name = name
		@filename = "#{@name}.db"
		@columns = columns
		@records = []
	end

	def retrieve_column_index(colname)
		index =	@columns.index colname
		if index.nil?
			raise Exception
		end	

		index
	end

	def insert(*attrs)
		record = Record.new(attrs)
		@records.push record
	end
	
	def write
		File.open(@filename, "w") do |f|
			@records.each do |record|
				serialized_record = record.write
				f.write(serialized_record + "\n")
			end
		end
	end

	def read
		puts "Warning!  Overwriting table!"
		@records = []

		read_data_and do |record|
			@records.push record
		end
	end

	def query
		Query.new @filename, self
	end
end
