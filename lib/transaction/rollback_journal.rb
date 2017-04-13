class RollbackJournal
    def initialize(db, *journal_files)
        @db = db
        @journal_files = journal_files
    end

    def prep
        @journal_files = create_journal_files
    end

    def discard
        delete_journal_files
    end

    def rollback
        overwrite_table_files
    end

    private
    def create_journal_files
        @db.get_table_files.collect do |table_file|
            journal_file = "#{table_file}.journal" 

            File.open(journal_file, "w") do |jf|
                File.copy_stream(table_file, jf)
            end

            journal_file
        end
    end

    def delete_journal_files
        @journal_files.each do |j|
            File.delete j
        end
    end

    def overwrite_table_files
        @journal_files.each do |journal_file|
            table_file = journal_file.rpartition(".")[0]
            File.rename(journal_file, table_file)
        end
    end
end
