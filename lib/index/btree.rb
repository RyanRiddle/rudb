require_relative 'node'

class BTree
	def initialize(order)
		@root = nil
		@order = order
	end	

	def insert(key, value)
		if @root.nil?
			@root = Node.new(@order)
		end	
		
		bucket = Bucket.new
		bucket.put value

		@root = @root.insert(key, bucket)
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
