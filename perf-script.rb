require 'benchmark'
require_relative 'lib/database'

def random_string
	(0...50).map { ('a'..'z').to_a[rand(26)] }.join
end
	

@db = Database.new "perf", "/tmp"

@table = @db.create_table "update"

Benchmark.bm do |x|
	x.report do ||
		str =  random_string()
		1_000_000.times do |id|
			@table.insert(id: id, string: str, score: rand(10))
		end
	end

	x.report { 
		@table.query().where({:id=>999999}).select(:id, :string, :score).top(1)
	}

=begin
	x.report { @table.query().top() }

	x.report { @table.query().update({:string=>random_string()}) }

	x.report { @table.query().top() }

	x.report { @table.query().update({:score=>5}) }

	x.report { @table.query().top() }

	x.report { @table.query().update({:score=>rand(10)}) }

	x.report { @table.query().top() }
=end
end

#db.drop_table("update")	
