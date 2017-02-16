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

	def select(*cols, where: {})
		results = []

		File.open(@filename, "r") do |f|
			until f.eof?
				serialized_record = f.readline
				record = Record::read serialized_record	

				add = true
				where.each do |col, value|
					index = retrieve_column_index col
					if not record.matches?(index, value)
						add = false
					end
				end

				if add
					results.push(record)
				end
			end
		end

		results
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
		
		File.open(@filename, "r") do |f|
			until f.eof?
				serialized_record = f.readline
				record = Record::read serialized_record
				@records.push record
			end
		end
	end
end
