require_relative 'record'

class Query
	def initialize(filename, table, db)
		@filename = filename
		@table = table
		@db = db

		@record_enumerator =
			Enumerator.new do |y|
				File.open(filename, "r") do |f|
					until f.eof?
						offset = f.tell
						header = f.readline
						deleted = header.split[0] != "0"
						length = header.split[1].to_i
						serialized_record = f.read length
						if not deleted
							record = Record::read serialized_record
							y.yield record, offset
						end	
					end
				end
			end.lazy
	end

	def top(num)
		@record_enumerator.take(num).force()
	end

	def update(clause = {})
		tmp_tbl = @db.create_table("tmp_tbl")

		updates = @record_enumerator.each do |record, offset|
			@table.mark(offset)
		
			record.set(clause)
			tmp_tbl.insert record
		end		

		@table.concat @db.get("tmp_tbl")
		@db.drop_table ("tmp_tbl")
	end

	def delete
		@record_enumerator.each do |record, offset|
			@table.mark offset
		end
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
end
