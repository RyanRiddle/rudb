class Node
	def initialize(key_type)
		@children = [nil]
		@keys = []
		@records = {}
		@key_type = key_type
	end

	def insert(record)
		if not internal?
			_insert record	
		else
			key = record.values_at(@key_type).first
			child_pos = find_pos key
			child = @children[child_pos]
			if not child.nil?
				child.insert record
			else
				raise Exception
			end
		end
	end

	def print(level)
		@keys.each_with_index do |key, i|
			if internal?
				@children[i].print(level + 1)
			end
			puts "\t" * level + key.to_s + @records[key].values_at(:name).first.to_s
		end
		if internal?
			@children.last.print(level + 1)
		end
	end

	private
	def _insert(record)
		key = record.values_at(@key_type).first

		pos = find_pos key	
		@keys.insert(pos, key)
		@children.push(nil)

		@records[key] = record
	end

	def internal?
		not @children.empty? and not @children.include? nil
	end

	def find_pos(key)
		# what about if they key already exists?
		pos = @keys.index do |k|
			key < k
		end

		pos ||= @keys.length

		pos
	end
end

class BTree
	def initialize(key_type, order)
		@root = nil
		@order = order
		@key_type = key_type
	end	

	def insert(record)
		if @root.nil?
			@root = Node.new(@key_type)
		end	
		@root.insert record
	end

	def print
		if not @root.nil?
			@root.print 0
		end
	end
end
