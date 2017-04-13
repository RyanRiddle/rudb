require_relative '../statement/statement'
require_relative 'record'

class TOO_LATE
end

class Table
	attr_reader :filename	# used to copy from one table to another
    attr_reader :db

	def initialize(filename, db)
		@db = db
		@filename = filename
        
        create_file_if_necessary
        create_synchronization_primitives
	end

	def destroy
		File.delete @filename
	end
	
	def concat(other_tbl)
        @file_mutex.synchronize do
            File.open(@filename, "a") do |f|
                File.copy_stream(other_tbl.filename, f)
            end	
        end
	end

	def insert record
		write record
	end
	
	def write(record)
        @file_mutex.synchronize do
            File.open(@filename, "a") do |f|
                serialized_record = record.serialize
                header = serialized_record.length
                f.puts header
                f.write serialized_record
            end
        end
	end

	def mark(record, offset, transaction_id)	# marks record deleted
        mutex = get_mutex offset
        cv = get_condition_variable offset
        commit_log = @db.commit_log

        mutex.synchronize do
            deleter_id = record.deleted_by

            while commit_log.in_progress? deleter_id
                cv.wait(mutex)
            end 

            if commit_log.committed? deleter_id
                puts "too late"
                cv.signal
                break TOO_LATE
            end

            _mark(offset, transaction_id)
            #cv.signal
        end
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

	def each_record(transaction)
		e = Enumerator.new do |y|
            File.open(@filename, "r") do |f|
                until f.eof?
                    offset = f.tell
                    header = f.readline
                    length = header.to_i
                    serialized_record = f.read length
                    record = Record::read serialized_record
                    if transaction.can_see? record
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

    private
    def _mark(offset, transaction_id)
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

    def get_mutex offset
        if @record_m_and_cv[offset].nil?
            @record_m_and_cv[offset] = [Mutex.new, ConditionVariable.new]
        end

        @record_m_and_cv[offset][0]
    end

    def get_condition_variable offset
        if @record_m_and_cv[offset].nil?
            @record_m_and_cv[offset] = [Mutex.new, ConditionVariable.new]
        end
        
        @record_m_and_cv[offset][1]
    end

    def create_file_if_necessary
		f = File.open @filename, "a"   # create if does not exist
		f.close
    end

    def create_synchronization_primitives
        @file_mutex = Mutex.new
        @record_m_and_cv = {}
    end
end
