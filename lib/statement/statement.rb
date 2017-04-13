require_relative '../data/record'
require_relative 'delete_command'
require_relative 'update_command'
require_relative 'insert_command'
require_relative 'select_statement'

class Statement
	def initialize(table, transaction)
		@table = table
		@db = table.db
        @transaction = transaction
		@record_enumerator = table.each_record(@transaction).lazy
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
        SelectStatement.new(@record_enumerator, @table, cols, @transaction.id)
    end

	def update(clause = {})
        UpdateCommand.new(@record_enumerator, @table, clause, @db, 
                            @transaction.id)
	end

	def delete
        DeleteCommand.new(@record_enumerator, @table, @transaction.id)
	end
    
    def insert(hash)
        InsertCommand.new(@table, hash, @transaction.id)
    end
end
