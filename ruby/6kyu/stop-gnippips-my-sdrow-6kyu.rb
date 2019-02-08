def spinWords(string)
        string.split(" ").map{ |w| w.length >= 5 ? w.reverse : w }.join(" ")
end

puts spinWords("This is another test")
