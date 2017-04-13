require_relative 'rollback_journal'

class Transaction
    attr_reader :rollback_mechanism
    attr_reader :id
    attr_reader :active_transactions

	def initialize(db, rollback_mechanism=nil)
        @id = db.next_transaction_id
        @commit_log = db.commit_log
        @results = []

=begin
        @rollback_mechanism = rollback_mechanism
        if @rollback_mechanism.nil?
            @rollback_mechanism = RollbackJournal.new db
        end
        #@rollback_mechanism.prep
=end

        @active_transactions = @commit_log.start @id
	end

	def add(&code)
        statement = code.call self
        if statement.is_a? DeleteCommand
            @cvs = statement.execute
        else
            @results.push statement.execute
            @results.last
        end
	end

	def commit
        @commit_log.commit @id
        if not @cvs.nil?
            @cvs.each do |cv|
                cv.signal
            end
        end
        #@rollback_mechanism.discard()
        @results
	end

    def rollback
        @commit_log.abort @id
        #@rollback_mechanism.rollback()
    end

    def can_see? record
        record.in_scope_for? @id, @active_transactions, @commit_log
    end
end


