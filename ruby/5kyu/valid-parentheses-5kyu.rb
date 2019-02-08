def valid_parentheses (string)
        score = 0
        string.chars.each { |c|
                case c
                when "("
                        score += 1
                when ")"
                        score -= 1
                end
                return false if score < 0
        }
        if score == 0 then
                return true
        else
                return false
        end
end

puts valid_parentheses "()"
puts valid_parentheses ")(()))"
puts valid_parentheses "("
puts valid_parentheses "(())((()())())"
