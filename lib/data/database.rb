require_relative 'table'
require_relative '../transaction/transaction.rb'
require_relative '../transaction/rollback_journal.rb'
require_relative '../transaction/id_generator.rb'
require_relative '../transaction/commit_log'

class Database
    attr_reader :commit_log

	def initialize(name, dir)
		@name = name
		@directory = File.join(dir, name)

        @transaction_id_generator = IdGenerator.new
        @generator_mutex = Mutex.new
        @commit_log = CommitLog.new

		@tables = {}
		if not Dir.exists? @directory
			Dir.mkdir @directory
		else
            load_tables
            rollback_failed_transactions
		end
	end

	def get(table)
		@tables[table]	
	end	

	def create_table(name)
		@tables[name] = Table.new name, @directory, self
	end

	def drop_table(name)
		tbl = @tables.delete name
		if not tbl.nil?
			tbl.destroy
		end
	end

    def next_transaction_id
        @generator_mutex.synchronize do
            @transaction_id_generator.next 
        end
    end

	private
    def load_tables
        get_table_files.each do |file|
            filename = file.split(".")[0]
            @tables[filename] = Table.new filename, @directory, self
        end
    end

	def get_table_files
		Dir.foreach(@directory).select do |filename|
            filename.rpartition(".").last == "db"
        end
	end

    def rollback_failed_transactions
        journal_files = find_journal_files

        if not journal_files.empty?
            journal = RollbackJournal.new *journal_files
            failed_transaction = Transaction.new(0, @commit_log, journal)
            failed_transaction.rollback
        end
    end

    def find_journal_files
        journal_files = Dir.foreach(@directory).select do |filename|
            filename.rpartition(".").last == "journal"
        end

        journal_files.collect { |filename| File.join @directory, filename }
    end
end
