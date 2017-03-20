class Transaction
	def initialize(db_dir)
		@commands = []
		@write_ahead_log = File.join(db_dir, "transaction.wal")
	end

	def add(command)
		@commands.push(command)
	end

	def commit
		output_wal()
        execute_commands()
        delete_wal()
	end

	def output_wal
		File.open(@write_ahead_log, "w") do |f|
			@commands.each do |command|
				command.render do |change|
                    f.puts change
                end
			end
			
			f.puts "LOG END"
		end
	end

    def execute_commands
        @commands.each do |command|
            command.execute()
        end
    end

    def delete_wal
        File.delete @write_ahead_log
    end
end


