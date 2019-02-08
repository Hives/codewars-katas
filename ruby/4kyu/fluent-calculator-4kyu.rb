class Calc

        @@numbers = {
                "zero" => 0,
                "one" => 1,
                "two" => 2,
                "three" => 3,
                "four" => 4,
                "five" => 5,
                "six" => 6,
                "seven" => 7,
                "eight" => 8,
                "nine" => 9
        }

        def initialize
                @terms = []
        end

        def result
                case @terms [1]
                when "plus"
                        return @terms[0] + @terms [2]
                when "minus"
                        return @terms[0] - @terms [2]
                when "times"
                        return @terms[0] * @terms [2]
                when "divided_by"
                        return @terms[0] / @terms [2]
                else
                        return nil
                end
        end

        @@numbers.each do |name, n|
                define_method name do
                        @terms += [n]
                        if @terms.size == 3
                                self.result
                        else
                                self
                        end
                end
        end

        ["plus", "minus", "times", "divided_by"].each do |operation|
                define_method operation do 
                        @terms += [operation]
                        self
                end
        end
end

Calc.new.one.plus.two             # Should return 3
Calc.new.five.minus.six           # Should return -1
Calc.new.seven.times.two          # Should return 14
Calc.new.nine.divided_by.three     # Should return 3

