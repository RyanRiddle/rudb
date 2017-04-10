require_relative '../util/eight_byte_string'
require_relative '../util/transaction_id'
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

    def deleted?
        @updater != 0
    end

	def set(clause = {})
		clause.each do |key, value|
			@hash[key] = value
		end
	end

	def serialize
        # @creator and @updater should be serialized with
        # a consistent length

		Marshal.dump([EightByteString.from_transaction_id(@creator),
                      EightByteString.from_transaction_id(@updater),
                      @hash])
	end

	def self.read(marshaled_record)
        array = Marshal.load marshaled_record
        creator = TransactionId.from_eight_byte_string array[0]
        updater = TransactionId.from_eight_byte_string array[1]
        hash    = array[2]
		Record.new creator, updater, hash
	end
end

