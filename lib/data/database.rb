require_relative 'table'
require_relative '../transaction/transaction.rb'
require_relative '../transaction/rollback_journal.rb'

class Database
	def initialize(name, dir=nil)
		@name = name
		@directory = if dir.nil?
			name
		else
			File.join(dir, name)
		end

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

	def begin_transaction
		Transaction.new @directory			
	end

	private
    def load_tables
        get_table_files.each do |file|
            filename = file.split(".")[0]
            @tables[filename] = Table.new filename, @directory, self
        end
    end

    def rollback_failed_transactions
        journal_files = get_journal_files.collect do |filename|
            File.join @directory, filename
        end
        if not journal_files.empty?
            journal = RollbackJournal.new *journal_files
            failed_transaction = Transaction.new journal
            failed_transaction.rollback
        end
    end
    
	def get_table_files
		Dir.foreach(@directory).select do |filename|
            filename.rpartition(".").last == "db"
        end
	end

    def get_journal_files
        Dir.foreach(@directory).select do |filename|
            filename.rpartition(".").last == "journal"
        end
    end
end
