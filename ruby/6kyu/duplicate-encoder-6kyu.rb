def duplicate_encode(word)
        letters = word.downcase.split("")
        output = ""
        letters.each do |l|
                if letters.count(l) > 1 then
                        output << ")"
                else
                        output << "("
                end
        end
        return output
end

puts duplicate_encode("recede")
