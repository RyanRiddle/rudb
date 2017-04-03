require_relative 'spec_helper.rb'

class DatabaseTest < Test::Unit::TestCase
    def test_insert
        table = create_db_with_table "nyc", "museum"

        table.statement.insert(id: 1, name: "MoMA", visited: true).execute
        result_set = table.statement.select(:name).top 1 
        assert result_set[0][0] == "MoMA"

        delete_tables_and_destroy_db "nyc", "museum"
    end

    def test_delete
        table = create_db_with_table "nyc", "museum"

        table.statement.insert(id: 1, name: "MoMA", visited: true).execute
        table.statement.delete.execute
        result_set = table.statement.top 1
        assert result_set.empty?

        sleep 1 # i think i need to get a lock before dropping a table
        delete_tables_and_destroy_db "nyc", "museum"
    end

    def test_update
        table = create_db_with_table "nyc", "museum"

        table.statement.insert(id: 1, name: "MoMA", visited: true).execute
        table.statement.insert(id: 2, name: "MET", visited: false).execute

        result_set = table.statement.where(visited: true).top 10
        assert result_set.length == 1

        table.statement.where(id: 2).update(visited: true).execute

        result_set = table.statement.where(visited: true).top 10
        assert result_set.length == 2

        sleep 1
        delete_tables_and_destroy_db "nyc", "museum"
    end
end
