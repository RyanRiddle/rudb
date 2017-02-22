require_relative 'query'
require_relative 'record'

class Table
	attr_reader :filename	# used to copy from one table to another

	@@file_mutex = Mutex.new

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
		Query.new self, @db
	end

	def cleanup
		Thread.new do 
			tmp_tbl = @db.create_table "tmp_tbl"

			self.each_record do |record, offset|
				tmp_tbl.write record
			end		

			@@file_mutex.synchronize {
				File.rename(tmp_tbl.filename, @filename)
			}

			@db.drop_table "tmp_tbl"
		end
	end

	def each_record
		e = Enumerator.new do |y|
			@@file_mutex.synchronize {
				File.open(@filename, "r") do |f|
					until f.eof?
						offset = f.tell
						header = f.readline
						deleted = header.split[0] != "0"
						length = header.split[1].to_i
						serialized_record = f.read length
						if not deleted
							record = Record::read serialized_record
							y.yield record, offset
						end	
					end
				end
			}
		end

		if not block_given?
			return e
		end

		e.each do |record, offset|
			yield record, offset
		end
	end
end
