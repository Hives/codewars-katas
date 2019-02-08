def accum(s)
        letters = s.downcase.split("")
        output = []
        for i in 0..(letters.length-1)
                output << "#{letters[i].upcase}#{letters[i]*i}"
        end
        return output.join("-")
end

puts accum("aalcZila")
