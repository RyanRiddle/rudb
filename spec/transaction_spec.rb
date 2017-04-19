require_relative 'spec_helper'

class TransactionTests < Test::Unit::TestCase
    def test_insert_and_select
        db, table = create_db_with_table "insert", "insert" 

        t = Transaction.new db
        t.add do |t|
            Statement.new(table, t).insert(id: 1, desc: "some data")
        end
        t.commit 

        t = Transaction.new db
        results = t.add do |t|
            Statement.new(table, t).select
        end
        t.commit
        
        assert results.count == 1 and results[0][:id] == 1 and
            results[0][:desc] == "some data"

        delete_tables_and_destroy_db "insert", "insert"
    end

    def test_update
        db, table = create_db_with_table "update", "update"

        t = Transaction.new db
        t.add do |t|
            Statement.new(table, t).insert(id: 1, desc: "some data")
        end
        t.add do |t|
            Statement.new(table, t).where(id: 1).update(desc: "updated data")
        end
        t.add do |t|
            Statement.new(table, t).where(id: 1).select(:desc)
        end
        t_results = t.commit

        assert t_results.last.count == 1 and 
            t_results.last[0] == "updated data"
        
        delete_tables_and_destroy_db "update", "update"
    end

    def test_delete
        db, table = create_db_with_table "delete", "delete"
        
        t = Transaction.new db
        t.add do |t|
            Statement.new(table, t).insert(id: 1, desc: "something")
        end
        t.add do |t|
            Statement.new(table, t).insert(id: 2, desc: "something else")
        end
        result = t.add do |t|
            Statement.new(table, t).select
        end

        assert result.count == 2

        t.add do |t|
            Statement.new(table, t).where(id: 2).delete
        end

        result = t.add do |t| Statement.new(table, t).select end

        assert result.count == 1

        t.commit

        delete_tables_and_destroy_db "delete", "delete" 
    end 
end
