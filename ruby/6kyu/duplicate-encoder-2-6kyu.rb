def duplicate_encode(word)
        word
                .downcase
                .chars
                .collect { |l| word.count(l) > 1 ? ")" : "(" }
                .join
end

puts duplicate_encode("Success")
