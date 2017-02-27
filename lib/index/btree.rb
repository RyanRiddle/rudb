class Node
	attr_accessor :parent
	def initialize(key_type, order, children=[nil], keys=[], records={})
		@key_type = key_type
		@order = order
		@children = children
		@keys = keys
		@records = records
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
			puts @records
			puts key
			puts "\t" * level + key.to_s + @records[key].values_at(:name).first.to_s
		end
		if internal?
			@children.last.print(level + 1)
		end
	end

	def accept(record, right_child)
		_insert(record, right_child)
	end

	private
	def split
		mid = (@order / 2).ceil
		right_keys = @keys.slice!(0, mid) 
		right_records = @records.select { |key, record| right_keys.include? key }
		right = Node.new(@key_type, @order, @children.slice!(0, mid),
						right_keys, 
						right_records)

		@records = @records.select { |key, record| @keys.include? key }
		left = self	
		return left, right
	end

	def _insert(record, child=nil)
		key = record.values_at(@key_type).first

		if @order - 1 == @keys.length
			left, right = split
			if @parent.nil?
				@parent = Node.new(@key_type, @order, [left])
			end
			left.parent = @parent
			right.parent = @parent
			return @parent.accept(record, right)
		end

		pos = find_pos key	
		@keys.insert(pos, key)
		@children.push(child)
		@records[key] = record

		@parent || self
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
			@root = Node.new(@key_type, @order)
		end	
		@root = @root.insert record
	end

	def print
		if not @root.nil?
			@root.print 0
		end
	end
end
