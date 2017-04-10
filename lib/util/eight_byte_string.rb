class EightByteString
    def self.from_transaction_id(id)
        [id].pack("q")
    end
end

