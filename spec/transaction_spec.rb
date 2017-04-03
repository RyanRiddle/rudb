require_relative 'spec_helper'

class TransactionTests < Test::Unit::TestCase
    def test_rollback_journal
        table = create_db_with_table "nyc", "restaurant"

        command = table.statement.insert(name: "Black Burger")
        commands = [command]

        rollback_journal = RollbackJournal.new
        rollback_journal.prep(commands)

        assert_block { File.exist? "#{table.filename}.journal" }

        rollback_journal.discard

        assert_block { not File.exist? "#{table.filename}.journal" }

        delete_tables_and_destroy_db "nyc", "restaurant"
    end

    def test_successful_transaction
        table = create_db_with_table "nyc", "restaurant"

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

        sleep 1     # you should really fix this
        delete_tables_and_destroy_db "nyc", "restaurant"
    end
end
