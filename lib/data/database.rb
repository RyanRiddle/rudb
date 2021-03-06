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

        @commit_log = CommitLog.new(File.join(@directory, "commit.log"))
        @transaction_id_generator = IdGenerator.new @commit_log.last_assigned_id
        @generator_mutex = Mutex.new

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
        filename = File.join(@directory, "#{name}.db")
		@tables[name] = Table.new filename, self
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

	def get_table_files
		names = Dir.foreach(@directory).select do |filename|
            filename.rpartition(".").last == "db"
        end

        names.collect { |name| File.join(@directory, name) }
	end

	private
    def load_tables
        get_table_files.each do |filename|
            basename = File.basename(filename, ".db")
            @tables[basename] = Table.new filename, self
        end
    end

    def rollback_failed_transactions
        if @commit_log.any_in_progress?
            @tables.each do |_, table|
                offset = table.has_bad_record?
                table.fix_bad_record offset
            end

            @commit_log.abort_all_in_progress
        end

=begin
        journal_files = find_journal_files

        if not journal_files.empty?
            journal = RollbackJournal.new self, *journal_files
            failed_transaction = Transaction.new self, journal
            failed_transaction.rollback
        end
=end
    end

    def find_journal_files
        journal_files = Dir.foreach(@directory).select do |filename|
            filename.rpartition(".").last == "journal"
        end

        journal_files.collect { |filename| File.join @directory, filename }
    end
end
