class TransactionId
    def self.from_eight_byte_string(byte_string)
        byte_string.unpack("q")[0]
    end
end
