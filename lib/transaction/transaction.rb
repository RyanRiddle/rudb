require 'pry'

class Transaction
    attr_reader :id
    attr_reader :active_transactions

	def initialize db
        @id = db.next_transaction_id
        @commit_log = db.commit_log
        @results = []

        @active_transactions = @commit_log.start @id

        if block_given?
            statement = yield self
            result = statement.execute
            @results.push result
            
            if not result.success?
                rollback
            end

            commit
        end
	end

	def add(&code)
        statement = code.call self
        result = statement.execute
        @results.push result

        if not result.success?
            rollback
        end

        result.result
	end

	def commit
        if @commit_log.in_progress? @id
            @commit_log.commit @id
            signal_condition_variables
        end
	end

    def rollback
        @commit_log.abort @id
        signal_condition_variables
    end

    def signal_condition_variables
        @results.each do |result|
            result.signal_condition_variables
        end
    end

    def can_see? record
        record.in_scope_for? @id, @active_transactions, @commit_log
    end

    private
    def execute_statement statement
        statement.execute
    end
end


