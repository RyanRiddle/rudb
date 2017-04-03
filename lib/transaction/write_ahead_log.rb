class WriteAheadLog
    def init(db_dir)
		@write_ahead_log = File.join(db_dir, "transaction.wal")
    end

    def rollback
    end
end
