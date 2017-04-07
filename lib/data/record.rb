require 'date'

class Record
	def initialize(creator, updater, hash)
        @creator = creator
        @updater = updater
		@hash = hash
	end

	def values_at(*keys)
		keys.empty? ? @hash : @hash.values_at(*keys)
	end

	def matches?(key, value)
		@hash[key] == value
	end

	def set(clause = {})
		clause.each do |key, value|
			@hash[key] = value
		end
	end

	def serialize
		Marshal.dump [@creator, @updater, @hash]
	end

	def self.read(marshaled_record)
		Record.new(*(Marshal.load marshaled_record))
	end
end

