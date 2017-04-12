require_relative '../data/record'
require_relative 'delete_command'
require_relative 'update_command'
require_relative 'insert_command'
require_relative 'select_statement'

class Statement
	def initialize(table, db, transaction_id)
		@table = table
		@db = db
        @transaction_id = transaction_id
		@record_enumerator = table.each_record(@transaction_id).lazy
	end

	def where(clause = {})
		@record_enumerator = @record_enumerator.select do |record, _|
			clause.all? do |key, value|
				record.matches?(key, value)
			end
		end

		return self
	end

	def select(*cols)
        SelectStatement.new(@record_enumerator, @table, cols, @transaction_id)
    end

	def update(clause = {})
        UpdateCommand.new(@record_enumerator, @table, clause, @db, 
                            @transaction_id)
	end

	def delete
        DeleteCommand.new(@record_enumerator, @table, @transaction_id)
	end
    
    def insert(hash)
        InsertCommand.new(@table, hash, @transaction_id)
    end
end
