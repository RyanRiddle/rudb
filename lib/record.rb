require 'date'

class Record
	def initialize(hash)
		@hash = hash
	end

	def values_at(*keys)
		keys.empty? ? @hash : @hash.values_at(*keys)
	end

	def matches?(key, value)
		@hash[key] == value
	end

	def serialize
		Marshal.dump @hash
	end

	def self.read(marshaled_record)
		Record.new(Marshal.load marshaled_record)
	end
end

