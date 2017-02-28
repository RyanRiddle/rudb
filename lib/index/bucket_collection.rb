require_relative 'bucket' 

class BucketCollection
	def initialize(buckets = {})
		@buckets = buckets
	end

	def include?(key)
		@buckets.include? key
	end

	def put(key, bucket)
		raise "Not a bucket" unless bucket.class == Bucket

		if include? key
			@buckets[key].concat bucket
		else
			@buckets[key] = bucket
		end
	end

	def get(key)
		@buckets[key]
	end

	def values_at(*keys)
		BucketCollection.new @buckets.select { |key, bucket| keys.include? key }
	end

	def delete(key)
		@buckets.delete key
	end

	def concat(buckets)
		# something crazy i did to avoid exposing the underlying hash
		if buckets.class == BucketCollection
			buckets.concat(@buckets)
		else
			BucketCollection.new @buckets.merge(buckets)
		end
	end
end


