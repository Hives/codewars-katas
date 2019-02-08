def getCount(inputStr)
        inputStr.downcase.chars.count { |x| ["a", "e", "i", "o", "u"].include? x }
end

puts getCount("greil marcus")
