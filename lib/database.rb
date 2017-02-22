require_relative 'table'

class Database
	def initialize(name, dir=nil)
		@name = name
		@directory = if dir.nil?
			name
		else
			File.join(dir, name)
		end

		@tables = {}
		if not Dir.exists? @directory
			Dir.mkdir @directory
		else
			getfiles.each do |file|
				filename = file.split(".")[0]
				@tables[filename] = Table.new filename, @directory, self
			end
		end
	end

	def get(table)
		@tables[table]	
	end	

	def create_table(name)
		@tables[name] = Table.new name, @directory, self
	end

	def drop_table(name)
		tbl = @tables.delete name
		if not tbl.nil?
			tbl.destroy
		end
	end

	private
	def getfiles
		Dir.foreach(@directory).select { |file| file != ".." and file != "." }
	end
end
