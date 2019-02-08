def find_next_square(sq)
        p = Math.sqrt(sq)
        p.floor == p ? ((p+1)**2).to_i : -1
end

puts find_next_square(121)
puts find_next_square(625)
puts find_next_square(114)
