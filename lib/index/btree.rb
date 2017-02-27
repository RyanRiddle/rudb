require 'pry'

class Node
	attr_accessor :parent
	attr_reader :records
	def initialize(key_type, order, children=[nil], keys=[], records={})
		@key_type = key_type
		@order = order
		@children = children
		@children.each do |child|
			if not child.nil?
				child.parent = self
			end
		end
		@keys = keys
		@records = records
	end

	def insert(record)
		if not internal?
			_insert record	
			@parent || self
		else
			key = record.values_at(@key_type).first
			child_pos = find_pos key
			child = @children[child_pos]
			child.insert record
			@parent || self
		end
	end

	def print(level)
		@keys.each_with_index do |key, i|
			if internal?
				@children[i].print(level + 1)
			end
			puts "\t" * level + "#{key} #{@records[key].values_at(:name).first}"
		end
		if internal?
			@children.last.print(level + 1)
		end
	end

	def accept(record, right_child)
		_insert(record, right_child)
	end

	def take_last
		last_key = @keys.last
		@keys.delete last_key

		#@children.delete_at(@children.length - 1)
		raise "Key/child mismatch" unless @keys.length == @children.length - 1

		last_record = @records.delete last_key
		last_record
	end

	private
	def split
		mid = (@order / 2.0).ceil

		right_keys = @keys.slice(mid, @keys.length)
		right_children = @children.slice(mid, @children.length)
		right_records = @records.select { |key, record| right_keys.include? key }
		right = Node.new(@key_type, @order, 
						right_children,
						right_keys, 
						right_records)

		@keys = @keys.slice(0, mid)
		@children = @children.slice(0, mid)
		@records = @records.select { |key, record| @keys.include? key }
		left = self

		return left, right
	end

	def _insert(record, child=nil)
		key = record.values_at(@key_type).first
		pos = find_pos key	
		@keys.insert(pos, key)
		@children.insert(pos+1, child)
		if not child.nil?
			child.parent = self
		end
		@records[key] = record

		if full?
			left, right = split

			if @parent.nil?
				#binding.pry
				@parent = Node.new(@key_type, @order, [left])
			end

			record_for_parent = left.take_last

			@parent.accept(record_for_parent, right)
		end

		@parent || self
	end

	def internal?
		#raise "bad kid!" #unless @children.all? { |child| child.nil? } or @children.all? { |child| not child.nil? }
		not @children.empty? and not @children.any? { |child| child.nil? }
	end

	def full?
		@order == @keys.length
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
		print
	end

	def print
		if not @root.nil?
			@root.print 0
		end
	end
end
