def queue_time(customers, n)
        tills = Array.new(n) { 0 }
        customers.each { |c| tills[tills.index(tills.min)] += c }
        tills.max
end

puts queue_time([5,3,4], 1)
puts queue_time([10,2,3,3], 2)
puts queue_time([2,3,10], 2)
