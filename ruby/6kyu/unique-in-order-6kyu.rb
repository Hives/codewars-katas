def unique_in_order(iterable)
        iterable = iterable.chars if iterable.respond_to? (:chars)
        output = []
        iterable.each { |i| output.push(i) if i != output [-1] }
        return output
end

puts unique_in_order('AAAABBBCCDAABBB') == ['A', 'B', 'C', 'D', 'A', 'B']
puts unique_in_order('ABBCcAD')         == ['A', 'B', 'C', 'c', 'A', 'D']
puts unique_in_order([1,2,2,3,3])       == [1,2,3]
