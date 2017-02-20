require_relative 'query'
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

class Table
	def initialize(name)
		@name = name
		@filename = "#{@name}.db"
	end

	def insert(row)
		record = Record.new row
		write record
	end
	
	def write(record)
		File.open(@filename, "a") do |f|
			serialized_record = record.serialize
			f.write(serialized_record.length.to_s + "\n")
			f.write(serialized_record)
		end
	end

	def query
		Query.new @filename, self
	end
end
