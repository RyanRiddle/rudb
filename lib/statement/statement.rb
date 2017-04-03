require_relative '../data/record'
require_relative 'delete_command'
require_relative 'update_command'
require_relative 'insert_command'

class Statement
	def initialize(table, db)
		@table = table
		@db = db

		@record_enumerator = table.each_record.lazy
	end

	def where(clause = {})
		@record_enumerator = @record_enumerator.select do |record, offset|
			clause.all? do |key, value|
				record.matches?(key, value)
			end
		end
		self
	end

	def select(*cols)
		@record_enumerator = @record_enumerator.map do |record, offset|
			record.values_at *cols
		end
		self		
	end

	def top(num=nil)
		if num.nil?
			return @record_enumerator.force()
		end

		@record_enumerator.take(num).force()
	end

	def update(clause = {})
        UpdateCommand.new(@record_enumerator, @table, clause, @db)
	end

	def delete
        DeleteCommand.new(@record_enumerator, @table)
	end
    
    def insert(hash)
        InsertCommand.new(@table, hash)
    end
end
