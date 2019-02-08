def rectangle_rotation(a, b)
  rt2 = Math.sqrt(2)
  rows = ((a/2)/(rt2/2)).floor * 2 + 1
  odd_rows = ((b/2)/rt2).floor * 2 + 1
  even_rows = ((((b/2)-(rt2/2))/rt2).floor + 1) * 2

  case rows % 4
  when 1
    odds = (rows/2.0).ceil
    evens = (rows/2.0).floor
  when 3
    odds = (rows/2.0).floor
    evens = (rows/2.0).ceil
  end

  (odds * odd_rows) + (evens * even_rows)
end

puts rectangle_rotation(4, 6)
puts rectangle_rotation(6, 4)
puts rectangle_rotation(30, 2)
puts rectangle_rotation(8, 6)
puts rectangle_rotation(16, 20)
