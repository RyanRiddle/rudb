require_relative 'bucket_collection'
require 'pry'

class Node
	attr_accessor :parent

	def initialize(order, children=[nil], keys=[], buckets=BucketCollection.new)
		@order = order
		@children = children
		@keys = keys
		@buckets = buckets

		@children.each { |child| child.parent = self unless child.nil? }
		@min_keys = ( @order / 2.0 ).ceil - 1
	end

	def insert(key, bucket)
		if @buckets.include? key
			@buckets.put(key, bucket)
		elsif not internal?
			_insert(key, bucket)
		else
			child_pos = find_pos key
			child = @children[child_pos]
			child.insert(key, bucket)
		end
			
		@parent || self
	end

	def delete(key)
		if @keys.include? key
			_delete key
		elsif internal?
			pos = find_pos key
			@children[pos].delete(key)
		end
	end

	def search(key)
		if @keys.include? key
			@buckets.get key
		elsif internal?
			pos = find_pos key
			@children[pos].search(key)
		else
			Bucket.new
		end
	end

	def print(level)
		@keys.each_with_index do |key, i|
			if internal?
				@children[i].print(level + 1)
			end
			puts "\t" * level + "#{key} #{@buckets.get key}"
		end
		if internal?
			@children.last.print(level + 1)
		end
	end

	def accept(key, bucket, right_child)
		_insert(key, bucket, right_child)
	end

	def take(key)
		@keys.delete key
		bucket = @buckets.delete key	
		deficient_node = if rebalance?
							self
						 else 
							nil 
						 end

		return key, bucket, deficient_node
	end

	def take_first
		first_key = @keys.first
		return take first_key
	end

	def take_last
		last_key = @keys.last
		return take last_key
	end

	def take_tree_max
		if not internal?
			return take_last
		else
			return @children.last.take_tree_max
		end
	end

	def take_lesser(child)
		pos = @children.find_index child
		
		if 0 < pos
			key = @keys[pos-1]
			return take key
		else
			raise "Could not find separator"
		end
	end

	def take_greater(child)
		pos = @children.find_index child
		
		if pos < @keys.length
			key = @keys[pos]
			return take key
		else
			raise "Could not find separator"
		end
	end

	def surrender
		return @keys, @children, @buckets
	end

	def has_surplus?
		@keys.length > @min_keys
	end

	def rebalance?
		@keys.length < @min_keys
	end

	def get_left_and_right(child)
		pos = @children.find_index child	
	
		left = nil
		right = nil
	
		if 0 < pos
			left = @children[pos-1]
		end

		if pos < @children.length - 1
			right = @children[pos+1]
		end

		return left, right
	end

	def __insert(key, bucket)
		pos = find_pos key	

		@keys.insert(pos, key)
		@buckets.put(key, bucket)
	end

	def steal(other)
		keys, children, buckets = other.surrender
		@keys.concat keys
		@children.concat children
		@buckets = @buckets.concat buckets

		# if joining two nodes at the bottom of the tree remove one of the leaves
		if not internal?
			@children.delete_at 0	# faster or slower than removing at end?
		else
			@children.each { |child| child.parent = self }
		end
	end

	def rebalance
		left_sibling, right_sibling = get_siblings
		if not right_sibling.nil? and right_sibling.has_surplus?
			parent_key, parent_bucket = take_greater_key_from_parent
			__insert parent_key, parent_bucket
			
			sibling_key, sibling_bucket = right_sibling.take_first
			@parent.__insert sibling_key, sibling_bucket
		elsif not left_sibling.nil? and left_sibling.has_surplus?
			parent_key, parent_bucket = take_lesser_key_from_parent
			__insert parent_key, parent_bucket

			sibling_key, sibling_bucket = left_sibling.take_last
			@parent.__insert sibling_key, sibling_bucket
		else 
			left = left_sibling ? left_sibling : self
			right = left_sibling ? self : right_sibling
			parent_key, parent_value = left_sibling ? 
										take_lesser_key_from_parent : 
										take_greater_key_from_parent

			left.__insert parent_key, parent_value
			left.steal(right)

			if left.parent.root? and left.parent.empty?
				left.parent = nil
			elsif left.parent.rebalance?
				left.parent.rebalance
			end

			return left.find_parent
		end	

		@parent.find_parent
	end

	def find_parent
		@parent ? @parent.find_parent : self
	end

	def root?
		@parent.nil?
	end

	def empty?
		@keys.empty?
	end

	private
	def split
		mid = (@order / 2.0).ceil

		right_keys = @keys.slice(mid, @keys.length)
		right_children = @children.slice(mid, @children.length)
		right_buckets = @buckets.values_at(*right_keys)
		right = Node.new(@order, 
						right_children,
						right_keys, 
						right_buckets)

		@keys = @keys.slice(0, mid)
		@children = @children.slice(0, mid)
		@buckets = @buckets.values_at(*@keys)
		left = self

		return left, right
	end

	def _insert(key, bucket, child=nil)
		pos = find_pos key	

		@keys.insert(pos, key)
		@children.insert(pos+1, child)
		@buckets.put(key, bucket)

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

	def get_siblings
		@parent.get_left_and_right self
	end

	def take_greater_key_from_parent
		@parent.take_greater self
	end

	def take_lesser_key_from_parent
		@parent.take_lesser self
	end

	def _delete(key)
		pos = find_pos key

		_, _, deficient_node = take key

		if internal?
			left_subtree = @children[pos]
			key, bucket, deficient_node = left_subtree.take_tree_max
			__insert(key, bucket)
		end

		if deficient_node
			return deficient_node.rebalance
		end

		find_parent
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

