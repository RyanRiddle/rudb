require_relative 'rollback_journal'

class Transaction
    attr_reader :rollback_mechanism
	def initialize(id, commit_log, rollback_mechanism=RollbackJournal.new)
        @id = id
        @rollback_mechanism = rollback_mechanism
		@commands = []
        @commit_log = commit_log
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


