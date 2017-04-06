require 'benchmark'
require_relative 'lib/data/database'

def updates_and_reads(x, table)
	x.report { 
		@table.statement.
            where({:id=>999999}).select(:id, :string, :score).top(1)
	}

	x.report { @table.statement.top() }

	x.report { @table.statement.update({:string=>random_string()}) }

	x.report { @table.statement.top() }

	x.report { @table.statement.update({:score=>5}) }

	x.report { @table.statement.top() }

	x.report { @table.statement.update({:score=>rand(10)}) }

	x.report { @table.statement.top() }
end

def random_string
	(0...50).map { ('a'..'z').to_a[rand(26)] }.join
end
	
@db = Database.new "perf", "/tmp"

@table = @db.create_table "update"

Benchmark.bm do |x|
	x.report do ||
		str = random_string()
		1_000_000.times do |id|
			@table.insert(id: id, string: str, score: rand(10))
		end
	end

    #x.report { @table.statement.top 1_000_000 }

    Thread.new do
        x.report { @table.statement.top 1_000_000 }
    end 

    Thread.new do
        x.report { @table.statement.top 1_000_000 }
    end 

    Thread.new do
        x.report { @table.statement.top 1_000_000 }
    end 

end

