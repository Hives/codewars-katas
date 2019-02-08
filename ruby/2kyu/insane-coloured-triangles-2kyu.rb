require 'benchmark'

def calc_triangle(row)
  # row = row.chars
  row = row.each_cons(2).map { |a, b| a == b ? a : ("RGB".chars - [a, b]).pop } until row.size == 1
  row[0]
end

def collapse(row)
  row = (0..(row.size-1)/3).to_a.map { |i| calc_triangle(row.slice(3 * i, (row.size - 1) % 3 + 1)) }
end

def triangle(row)
  row = row.chars
  row = collapse(row) until row.size == 1
  row[0]
end

p triangle("GRR")
p triangle("BRBRBBBRG")
p triangle("GGGGBBGB")