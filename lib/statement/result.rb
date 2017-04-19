module Result
    attr_reader :result

    def initialize(result, ms_and_cvs={})
        @result = result
        @ms_and_cvs = ms_and_cvs
    end

    def signal_condition_variables
        @ms_and_cvs.each do |m, cv|
            m.synchronize do
                cv.signal
            end
        end
    end
end

class SuccessfulStatement
    include Result

    def success?
        true
    end
end

class FailedStatement
    include Result
    
    def success?
        false
    end
end
