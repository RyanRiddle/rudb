require_relative 'spec_helper'

class TransactionTests < Test::Unit::TestCase
    def test_failed_transaction
        db, table = create_db_with_table "two", "restaurant"

        Transaction.new db do |t|
            Statement.new(table, t).insert(name: "one lonely restaurant")
        end

        t = Transaction.new db
        results = t.add do |t|
            Statement.new(table, t).select
        end
        t.commit
        puts results

        assert results.length == 1

        thread = Thread.new do
            t = Transaction.new db
            100_000.times do
                t.add do |t|
                    Statement.new(table, t).
                        insert(name: "another garbage row")
                end
            end
            t.commit
        end

        while not thread.status == "run"
            puts "waiting"
        end
        
        Thread.kill thread

        # "restart" the database
        db = Database.new "two", "/tmp"
        table = db.get "restaurant"

        t = Transaction.new db
        result_set = t.add do |t|
            Statement.new(table, t).select
        end
        t.commit

        assert_block do 
            result_set.length == 1
        end

        delete_tables_and_destroy_db "two", "restaurant"
    end

    def test_successful_transaction
        db, table = create_db_with_table "three", "restaurant"

        transaction = Transaction.new db

        transaction.add do |t|
            Statement.new(table, t).
                insert(name: "Black Burger", type: "burgers")
        end
        transaction.add do |t|
            Statement.new(table, t).
                insert(name: "Golden Steamer", type: "dumplings")
        end
        transaction.add do |t|
            Statement.new(table, t).
                where(type: "dumplings").
                update(type: "buns")
        end
        transaction.add do |t|
            Statement.new(table, t).
                where(type: "burgers").delete
        end

        transaction.commit

        transaction = Transaction.new db
        result_set = transaction.add do |t|
            Statement.new(table, t).select(:name, :type)
        end
        transaction.commit

        assert_block do 
            result_set.length == 1 and 
            result_set[0][0] == "Golden Steamer" and
            result_set[0][1] == "buns"
        end

        delete_tables_and_destroy_db "three", "restaurant"
    end
end
