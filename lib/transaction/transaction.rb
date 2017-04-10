class Transaction
    attr_reader :rollback_mechanism
	def initialize(rollback_mechanism)
		@commands = []
        @rollback_mechanism = rollback_mechanism
	end

	def add(command)
		@commands.push(command)
	end

	def commit(transaction_id)
        @rollback_mechanism.prep(@commands)
        execute_commands(transaction_id)
        @rollback_mechanism.discard()
	end

    def rollback
        @rollback_mechanism.rollback()
    end
   
    private 
    def execute_commands(transaction_id)
        @commands.each do |command|
            command.execute(transaction_id)
        end
    end
end


