require_relative '../util/eight_byte_string'
require_relative '../util/transaction_id'
require 'date'

class Record
    attr_accessor :updater
    attr_reader :hash

	def self.read(marshaled_record)
        array = Marshal.load marshaled_record
        creator = TransactionId.from_eight_byte_string array[0]
        hash    = array[2]
        updater = TransactionId.from_eight_byte_string array[1]
		Record.new creator, hash, updater
	end
    
    def self.copy transaction_id, other
        Record.new transaction_id, other.hash, 0
    end

	def initialize(creator, hash, updater=0)
        @creator = creator
		@hash = hash
        @updater = updater
	end

	def values_at(*keys)
		keys.empty? ? @hash : @hash.values_at(*keys)
	end

	def matches?(key, value)
		@hash[key] == value
	end

    def in_scope_for? transaction_id
        not deleted? transaction_id and 
            @creator <= transaction_id
    end

    def deleted_by
        @updater
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

    private
    def deleted? transaction_id
        0 < @updater and @updater <= transaction_id
    end
    
end

