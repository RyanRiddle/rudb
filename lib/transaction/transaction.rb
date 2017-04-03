class Transaction
	def initialize(rollback_mechanism)
		@commands = []
        @rollback_mechanism = rollback_mechanism
	end

	def add(command)
		@commands.push(command)
	end

	def commit
        @rollback_mechanism.prep(@commands)
        execute_commands()
        @rollback_mechanism.discard()
	end

    def rollback
        @rollback_mechanism.rollback()
    end
   
    private 
    def execute_commands
        @commands.each do |command|
            command.execute()
        end
    end
end


