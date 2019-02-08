def printer_errors(s)
        sum = 0
        "nopqrstuvwxyz".chars.each { |l|
                sum += s.count(l)
        }
        return "#{sum}/#{s.length}"
end

puts printer_errors "abcdefn"
