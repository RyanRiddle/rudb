require 'test/unit'
require_relative '../lib/data/database'

class DatabaseTest < Test::Unit::TestCase
    def test_create_database
        db = Database.new("nyc", "/tmp")

        assert(Dir.exist? "/tmp/nyc")

        Dir.delete "/tmp/nyc" 
    end

    def test_table
        db = Database.new("nyc", "/tmp")
        db.create_table "museum"

        museum_table = db.get "museum"

        assert_not_nil museum_table
        assert File.exist? museum_table.filename

        db.drop_table "museum"

        assert_block { not File.exist? museum_table.filename }

        Dir.delete "/tmp/nyc"
    end
end
