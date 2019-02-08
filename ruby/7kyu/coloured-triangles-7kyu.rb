require 'benchmark'

def triangle(row)
  row = row.chars
  row = row.each_cons(2).map { |a, b| a == b ? a : ("RGB".chars - [a, b]).pop } until row.size == 1
  row[0]
end

tests = []
10000.times do
  test = ""
  20.times do
    test += "RGB".chars.sample
  end
  tests += [test]
end

puts Benchmark.measure { tests.each { |test| triangle(test) } }