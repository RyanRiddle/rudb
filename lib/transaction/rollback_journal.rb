class RollbackJournal
    def initialize(*journal_files)
        @journal_files = journal_files
    end

    def prep(commands)
        create_journal_files commands
    end

    def discard
        delete_journal_files
    end

    def rollback
        @journal_files.each do |journal_file|
            table_file = journal_file.rpartition(".")[0]
            File.rename(journal_file, table_file)
        end
    end

    private
    def get_filenames(commands)
        table_files = commands.collect { |command| command.table.filename }
        table_files.uniq
    end
    
    def create_journal_files(commands)
        table_files = get_filenames commands
        table_files.each do |table_file|
            journal_file = "#{table_file}.journal" 

            File.open(journal_file, "w") do |jf|
                File.copy_stream(table_file, jf)
            end

            @journal_files.push journal_file
        end
    end

    def delete_journal_files
        @journal_files.each do |j|
            File.delete j
        end
    end
end
