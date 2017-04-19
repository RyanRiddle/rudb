require_relative 'spec_helper'

class TransactionTests < Test::Unit::TestCase
    def test_rollback_journal
        table = create_db_with_table "one", "restaurant"

        command = table.statement.insert(name: "Black Burger")
        commands = [command]

        rollback_journal = RollbackJournal.new
        rollback_journal.prep(commands)

        assert_block { File.exist? "#{table.filename}.journal" }

        rollback_journal.discard

        assert_block { not File.exist? "#{table.filename}.journal" }

        delete_tables_and_destroy_db "one", "restaurant"
    end

    def test_failed_transaction
        table = create_db_with_table "two", "restaurant"

        table.statement.insert(name: "one lonely restaurant").execute

        assert table.statement.top(100).length == 1

        commands = 100_000.times.map do
            table.statement.insert(name: "another garbage row")
        end

        rj = RollbackJournal.new
        transaction = Transaction.new rj
        commands.each { |c| transaction.add c }

        thread = Thread.new { transaction.commit }
        
        while not File.exist? "#{commands.last.table.filename}.journal"
            # make sure the commit thread is running
            puts "waiting for transaction to start"
        end
    
        Thread.kill thread

        # "restart" the database
        db = Database.new "two", "/tmp"
        table = db.get "restaurant"

        result_set = table.statement.top 1000
        assert_block do 
            result_set.length == 1
        end

        delete_tables_and_destroy_db "two", "restaurant"
    end

    def test_successful_transaction
        table = create_db_with_table "three", "restaurant"

        commands = [table.statement.
                        insert(name: "Black Burger", type: "burgers"),
                    table.statement.
                        insert(name: "Golden Steamer", type: "dumplings"),
                    table.statement.where(type: "dumplings").
                        update(type: "buns"),
                    table.statement.where(type: "burgers").delete]
                        
        transaction = Transaction.new RollbackJournal.new
        commands.each { |c| transaction.add c }
        transaction.commit

        result_set = table.statement.select(:name, :type).top 10
        assert_block do 
            result_set.length == 1 and 
            result_set[0][0] == "Golden Steamer" and
            result_set[0][1] == "buns"
        end

        delete_tables_and_destroy_db "three", "restaurant"
    end
end
