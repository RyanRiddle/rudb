class Bucket
	def initialize(values = [])
		@values = values
	end

	def put(value)
		@values.push(value)
	end

	def concat(bucket)
		@values.concat bucket.to_ary
	end

	def to_ary
		Array.new @values	# for immutability
	end
end

