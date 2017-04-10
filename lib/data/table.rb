require_relative '../statement/statement'
require_relative 'record'

class Table
	attr_reader :filename	# used to copy from one table to another

	@@file_mutex = Mutex.new

	def initialize(name, dir, db)
		@db = db
		@name = name
		@filename = File.join(dir, "#{@name}.db")
		f = File.open @filename, "r+"   # r+ because we do not want to overwrite
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

	def insert(row, transaction_id)
		# This code smells
=begin
		if row.class == Record
			record = row
		else
			record = Record.new transaction_id, 0, row
		end
=end
        record = Record.new transaction_id, 0, row

		write record
	end
	
	def write(record)
		File.open(@filename, "a") do |f|
			serialized_record = record.serialize
			header = serialized_record.length
			f.puts header
			f.write serialized_record
		end
	end

	def mark(offset, transaction_id)	# marks record deleted
        told = nil
        record = nil

        File.open(@filename, "r") do |f|
            f.seek(offset)
            length = f.readline.to_i

            told = f.tell

            serialized_record = f.read length
            record = Record.read serialized_record

            record.updater = transaction_id
        end
           
        File.write @filename, record.serialize, told
	end

	def statement transaction_id
		Statement.new self, @db, transaction_id
	end

	def cleanup
        # commenting out until i have mvcc implemented
=begin
		Thread.new do 
			tmp_tbl = @db.create_table "tmp_tbl"

			self.each_record do |record, offset|
				tmp_tbl.write record
			end		

            ReadWriteLock.write @@file_mutex do
				File.rename(tmp_tbl.filename, @filename)
			end

			@db.drop_table "tmp_tbl"
		end
=end
	end

	def each_record(transaction_id)
		e = Enumerator.new do |y|
            File.open(@filename, "r") do |f|
                until f.eof?
                    offset = f.tell
                    header = f.readline
                    length = header.to_i
                    serialized_record = f.read length
                    record = Record::read serialized_record
                    if record.in_scope_for? transaction_id
                        y.yield record, offset
                    end	
                end
            end
		end

		if not block_given?
			return e
		end

		e.each do |record, offset|
			yield record, offset
		end
	end
end
