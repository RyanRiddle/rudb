class Bucket
	def initialize()
	end
end

class Node
	attr_accessor :parent

	def initialize(order, children=[nil], keys=[], buckets={})
		@order = order
		@children = children
		@keys = keys
		@buckets = buckets

		@children.each { |child| child.parent = self unless child.nil? }
	end

	def insert(key, value)
		if @buckets.include? key
			@buckets[key].push(value)
		elsif not internal?
			_insert(key, [value])
		else
			child_pos = find_pos key
			child = @children[child_pos]
			child.insert key, value
		end
			
		@parent || self
	end

	def search(key)
		if @keys.include? key
			@buckets[key]
		elsif internal?
			pos = find_pos key
			@children[pos].search(key)
		else
			nil
		end
	end

	def print(level)
		@keys.each_with_index do |key, i|
			if internal?
				@children[i].print(level + 1)
			end
			puts "\t" * level + "#{key} #{@buckets[key]}"
		end
		if internal?
			@children.last.print(level + 1)
		end
	end

	def accept(key, bucket, right_child)
		_insert(key, bucket, right_child)
	end

	def take_last
		last_key = @keys.last
		@keys.delete last_key

		last_bucket = @buckets.delete last_key
		return last_key, last_bucket
	end

	private
	def split
		mid = (@order / 2.0).ceil

		right_keys = @keys.slice(mid, @keys.length)
		right_children = @children.slice(mid, @children.length)
		right_buckets = @buckets.select { |key, value| right_keys.include? key }
		right = Node.new(@order, 
						right_children,
						right_keys, 
						right_buckets)

		@keys = @keys.slice(0, mid)
		@children = @children.slice(0, mid)
		@buckets = @buckets.select { |key, value| @keys.include? key }
		left = self

		return left, right
	end

	def _insert(key, bucket, child=nil)
		pos = find_pos key	

		@keys.insert(pos, key)
		@children.insert(pos+1, child)
		@buckets[key] = bucket

		if not child.nil?
			child.parent = self
		end

		if full?
			left, right = split

			if @parent.nil?
				@parent = Node.new(@order, [left])
			end

			key_for_parent, bucket_for_parent = left.take_last

			@parent.accept(key_for_parent, bucket_for_parent, right)
		end

		@parent || self
	end

	def internal?
		raise "bad kid!" unless @children.all? { |child| child.nil? } or @children.all? { |child| not child.nil? }

		not @children.empty? and not @children.any? { |child| child.nil? }
	end

	def full?
		@order == @keys.length
	end

	def find_pos(key)
		# what about if they key already exists?
		pos = @keys.index do |k|
			key <= k
		end

		pos ||= @keys.length

		pos
	end
end

class BTree
	def initialize(order)
		@root = nil
		@order = order
	end	

	def insert(key, value)
		if @root.nil?
			@root = Node.new(@order)
		end	
		@root = @root.insert key, value
		print
	end

	def print
		if not @root.nil?
			@root.print 0
		end
	end

	def search(key)
		@root.search(key)
	end
end
