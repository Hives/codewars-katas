odds_n_ends = [:weezard, 42, "Trady Blix", 3, true, 19, 12.345]

# Add your code below!
ints = odds_n_ends.select { |e| e.is_a? Integer }

puts ints
