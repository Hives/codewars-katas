class Calculator
        def evaluate(string)
                @terms = string.split
                ["*", "/", "+", "-"].each do |o|
                        while i = @terms.index(o)
                                @terms[i] = @terms[i-1].to_f.send(o, @terms[i+1].to_f)
                                @terms.delete_at(i+1)
                                @terms.delete_at(i-1)
                        end
                end
                out = @terms[0]
                out.to_i == out ? out.to_i : out
        end
end

calc = Calculator.new
puts calc.evaluate("4 + 5")
puts calc.evaluate("4 * 5")
puts calc.evaluate("4 + 5 + 6 + 7")
puts calc.evaluate("4 / 5")
puts calc.evaluate("4 - 5")
puts calc.evaluate("4 + 5 * 6")
