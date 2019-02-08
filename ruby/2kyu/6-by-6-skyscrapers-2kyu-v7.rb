require 'benchmark'

class Puzzle

  def initialize(clues)

    @d = clues.size/4
    @c = {
      r: Array.new(@d){|i| { f: clues[-(i + 1)], b: clues[@d + i] } },
      c: Array.new(@d){|i| { f: clues[i], b: clues[-(i + 1 + @d)] } }
    }
    @s = Array.new(@d) { Array.new (@d) { (1..@d).to_a }}
    @g = []
    @failed = false
    @count_method_use = {}
    @printy = false
    @printy_count = 0

    [:r, :c].each do |r_or_c|
      (0..@d-1).each do |i|
        row = get_r_or_c(r_or_c, i)
        [:f, :b].each do |f_or_b|
          clue = @c[r_or_c][i][f_or_b]
          row.reverse! if f_or_b == :b
          if clue == 1
            row[0] = @d
          elsif clue != 0
            (0..clue-2).each do |n|
              row[n] -= (@d+2+n-clue..@d).to_a
            end
          end
          row.reverse! if f_or_b == :b
        end
        set_r_or_c(r_or_c, i, row)
      end
    end

  end

  def get_r_or_c(r_or_c, i)
    return r_or_c == :r ? @s[i] : @s.transpose[i]
  end

  def set_r_or_c(r_or_c, j, row)
    @s = @s.transpose if r_or_c == :c
    (0..@d-1).each { |i| @s[j][i] = row[i] }
    @s = @s.transpose if r_or_c == :c
    return row
  end

  def no_duplicates_rule
    # only one of each number allowed in each row + column
    # looks for solved cells and removes that no. from row/col possibilities
    count_method_use
    method_printy

    changed = "no change"
    [:r, :c].each do |r_or_c|
      (0..@d-1).each do |i|
        row = get_r_or_c(r_or_c, i)
        solved = row.select{ |n| n.is_a? Integer }
        if solved.size > 0 && solved.size < @d
          row.map! do |cell|
            if cell.is_a? Array
              original_size = cell.size
              cell -= solved
              changed = "changed" if cell.size != original_size
              return false if cell.size == 0
              cell = cell[0] if cell.size == 1
            end
            cell
          end
          new_solved = row.select{ |n| n.is_a? Integer }
          return false if new_solved.uniq.size != new_solved.size
          set_r_or_c(r_or_c, i, row)
        end
      end
    end
    printy
    return changed
  end

  def no_other_option_rule
    # if a number can only go in one cell of a row or column then it must go
    # there
    method_printy
    count_method_use
    [:r, :c].each do |r_or_c|
      (0..@d-1).each do |i|
        row = get_r_or_c(r_or_c, i)
        remaining = row.select{ |cell| cell.is_a? Array }.flatten
        unique_remaining = remaining.select{ |n| (remaining.count n) == 1 }
        if unique_remaining.size > 0
          row.map! do |cell|
            if cell.is_a? Array
              intersection = cell & unique_remaining
              cell = (intersection.size == 1) ? intersection[0] : cell
            end
            cell
          end
          set_r_or_c(r_or_c, i, row)
          return false if no_duplicates_rule == false
        end
      end
    end
    printy
    return true
  end

  def roolz
    method_printy
    count_method_use

    old_square = Marshal.load(Marshal.dump(@s))

    loop do
      result = no_duplicates_rule
      break if result == "no change"
      return "invalid" if result == false
    end

    return "invalid" if no_other_option_rule == false
    return "invalid" if check_square == false

    printy

    return "it changed" if @s != old_square
    return "no change"
  end

  def make_a_guess
    # find a cell to guess
    method_printy
    count_method_use
    i = 0; j = 0
    while !@s[j][i].is_a? Array
      i += 1
      if i == @d
        i = 0; j += 1
      end
    end

    options = @s[j][i]
    guess = options[0]
    remaining_options = options - [guess]

    puts "(#{i}, #{j}) -> #{guess}" if @printy

    @g += [{
      square: Marshal.load(Marshal.dump(@s)),
      i: i,
      j: j,
      guess: guess,
      remaining_options: remaining_options,
    }]
    @s[j][i] = guess
    no_duplicates_rule
  end

  def a_guess_was_wrong
    method_printy
    count_method_use

    last_guess = []
    loop do
      last_guess = @g.pop
      break if last_guess[:square][last_guess[:j]][last_guess[:i]].size >= 2
    end

    @s = Marshal.load(Marshal.dump(last_guess[:square]))
    printy

    remaining_options = last_guess[:remaining_options]
    if remaining_options.size == 1
      @s[last_guess[:j]][last_guess[:i]] = remaining_options[0]
    else
      @s[last_guess[:j]][last_guess[:i]] = remaining_options
      make_a_guess
    end

    self.printy

  end

  def printy(force=false)
    return if !@printy && !force
    puts "printy #{@printy_count += 1}"
    col_width = @s.flatten(1).map{|a| a.to_s.delete(" ") }.max_by(&:length).size
    # col_width = (2 * @d + 1)

    print "  "
    @c[:c].each{ |col_clues| print col_clues[:f].to_s.center(col_width + 1) }
    print "\n"

    @s.each_with_index do |row, i|
      print @c[:r][i][:f].to_s + " "
      row.each do |cell|
        print cell.to_s.delete(' ').center(col_width, ".") + " "
      end
      print @c[:r][i][:b].to_s + " "
      puts "\n"
    end

    print "  "
    @c[:c].each{ |col_clues| print col_clues[:b].to_s.center(col_width + 1) }
    print "\n"

  end

  def method_printy
    return if !@printy
    method = caller[0][/`.*'/][1..-2]
    puts "----- Applying #{method} -----"
  end

  def count_method_use
    method = caller[0][/`.*'/][1..-2].to_s
    if @count_method_use.has_key? method
      @count_method_use[method] += 1
    else
      @count_method_use[method] = 1
    end
  end

  def check_square
    count_method_use
    method_printy
    # checks the whole solution to see if it agrees with the clues
    [:r, :c].each do |r_or_c|
      (0..@d-1).each do |i|
        return false if check_row_or_col(r_or_c, i) == false
      end
    end
    true
  end

  def check_row_or_col(r_or_c, i)
    method_printy
    # checks a row or column to see if it agrees with the clues

    row = get_r_or_c(r_or_c, i)

    [:f, :b].each do |f_or_b|

      if @c[r_or_c][i][f_or_b] != 0
        solved = row.select{|cell| cell.class == Integer}
        solved.reverse! if f_or_b == :b

        # only checks against clue if all cells in row are 'solved' (quite lame)
        if solved.size == @d
          count = 0
          solved.each_with_index do |n, j|
            if j == 0
              count += 1
            else
              count += 1 if n > solved[0..j-1].max
            end
          end
          if count != @c[r_or_c][i][f_or_b]
            # p false
            @failed = true
            return false 
          end
        end
      end

    end

    # p true
    return true

  end

  def solve
    # @printy = true

    loop do
      effect_of_roolz = roolz
      a_guess_was_wrong if effect_of_roolz == "invalid"
      if effect_of_roolz == "no change"
        if @s.flatten(1) == @s.flatten(2)
          break
        else
          make_a_guess
        end
      end
    end

    printy(true)
    p @count_method_use

  end

end

def solve_puzzle(clues)
  p = Puzzle.new(clues)
  p.solve
end

clues1 = [ 3, 2, 2, 3, 2, 1,
           1, 2, 3, 3, 2, 2,
           5, 1, 2, 2, 4, 3,
           3, 2, 1, 2, 2, 4]

clues2 = [ 0, 0, 0, 2, 2, 0,
           0, 0, 0, 6, 3, 0,
           0, 4, 0, 0, 0, 0,
           4, 4, 0, 3, 0, 0]

clues3 = [ 0, 3, 0, 5, 3, 4,
           0, 0, 0, 0, 0, 1,
           0, 3, 0, 3, 2, 3,
           3, 2, 0, 3, 1, 0]

clues4 = [0, 3, 0, 3, 2, 3,
          3, 2, 0, 3, 1, 0,
          0, 3, 0, 5, 3, 4,
          0, 0, 0, 0, 0, 1]

clues5 = [0, 3, 0, 3, 2, 3,
          3, 2, 0, 3, 1, 0,
          0, 3, 0, 5, 3, 4,
          0, 0, 0, 0, 0, 1]

# [clues1, clues2, clues3, clues4, clues5].each do |clues|
[clues5].each do |clues|
  puts Benchmark.measure { solve_puzzle(clues) }
end


#   clues    = [0, 0, 1, 2,
#               0, 2, 0, 0,
#               0, 3, 0, 0,
#               0, 1, 0, 0]

# puts Benchmark.measure { solve_puzzle(clues) }
