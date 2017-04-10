class SelectStatement
    def initialize(record_enumerator, table, cols, transaction_id)
        @record_enumerator = record_enumerator
        @table = table
        @cols = cols
        @transaction_id = transaction_id
	end

	def top num
        @limit = num
        
        return self
	end
    
    def execute
        reduce_dimensions!
        take_results
    end

    private
    def reduce_dimensions!
        # use map instead of map! because Enumerator::Lazy does not have it
		@record_enumerator = @record_enumerator.map do |record, _|
			record.values_at *@cols
		end
    end

    def take_results
		if @limit.nil?
			@record_enumerator.force()
        else
            @record_enumerator.take(@limit).force()
        end
    end
end
