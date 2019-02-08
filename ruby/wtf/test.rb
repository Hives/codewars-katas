require 'benchmark'

a = (0..99).to_a

puts Benchmark.measure {
  1000.times do
    a.each_with_index{ |n, i| n*100 }
  end
}

puts Benchmark.measure {
  1000.times do
    (0..99).to_a.each{ |i| a[i]*100 }
  end
}
