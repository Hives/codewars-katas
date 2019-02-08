def find_it(seq)
        seq.each { |i|
                return i if seq.count(i) % 2 == 1
        }
end

puts find_it([20,1,-1,2,-2,3,3,5,5,1,2,4,20,4,-1,-2,5])
puts find_it([1,1,2,-2,5,2,4,4,-1,-2,5])
puts find_it([20,1,1,2,2,3,3,5,5,4,20,4,5])
puts find_it([10])
puts find_it([1,1,1,1,1,1,10,1,1,1,1])
