require 'test/unit'
require_relative '../lib/data/database'

def create_db_with_table(db_name, table_name)
    db = Database.new db_name, "/tmp"
    db.create_table table_name
    table = db.get table_name
    return db, table
end

def delete_tables_and_destroy_db(db_name, table_name)
    db = Database.new db_name, "/tmp"
    db.drop_table table_name
    File.delete(File.join "/tmp", db_name, "commit.log")
    Dir.delete File.join("/tmp", db_name)
end

