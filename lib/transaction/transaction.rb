require_relative 'rollback_journal'

class Transaction
    attr_reader :rollback_mechanism
	def initialize(db, rollback_mechanism=RollbackJournal.new)
        @id = db.next_transaction_id
        @commit_log = db.commit_log
        @rollback_mechanism = rollback_mechanism
		@commands = []
	end

	def add(command)
		@commands.push(command)
	end

	def commit
        @rollback_mechanism.prep(@commands)

        @commit_log.start @id
        results = execute_commands()
        @commit_log.commit @id

        @rollback_mechanism.discard()

        results
	end

    def rollback
        @rollback_mechanism.rollback()
    end
   
    private 
    def execute_commands
        @commands.collect { |command| command.execute }
    end
end


