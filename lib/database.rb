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
				@tables[filename] = Table.new filename, @directory
			end
		end
	end

	def get(table)
		@tables[table]	
	end	

	def create_table(name)
		@tables[name] = Table.new name, @directory
	end

	def getfiles
		Dir.foreach(@directory).select { |file| file != ".." and file != "." }
	end
end
