# don't use deduction, only guesses (except when the rule functions are used
# to check validity...)

require 'benchmark'

class Puzzle

  def initialize(clues)

    @d = clues.size/4
    @c = {
      r: Array.new(@d){|i| { f: clues[-(i + 1)], b: clues[@d + i] } },
      c: Array.new(@d){|i| { f: clues[i], b: clues[-(i + 1 + @d)] } }
    }
    @s = Array.new(@d) { Array.new(@d) { (1..@d).to_a } }
    @g = []
    @failed = false
    @count = {
      rule_0: 0,
      rule_1: 0,
      rule_2: 0,
      check_square: 0,
      make_a_guess: 0,
      a_guess_was_wrong: 0
    }
    @printy = false

    [:r, :c].each do |r_or_c|
      @s = @s.transpose if r_or_c == :c

      @s.map!.each_with_index do |row, i|
        [:f, :b].each do |f_or_b|
          row.reverse! if f_or_b == :b
          if @c[r_or_c][i][f_or_b] == 1
            row[0] = [@d]
          elsif @c[r_or_c][i][f_or_b] != 0
            (0..@c[r_or_c][i][f_or_b]-2).each do |n|
              row[n] -= (@d+2+n-@c[r_or_c][i][f_or_b]..@d).to_a
            end
          end
          row.reverse! if f_or_b == :b
        end
        row
      end

      @s = @s.transpose if r_or_c == :c
    end
    self.rule_0

  end

  def printy
    return if !@printy
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
    puts "----- Applying #{caller[0][/`.*'/][1..-2]} -----"
  end

  def rule_0
    self.method_printy
    @count[:rule_0] += 1
    # if only one number can go in a cell then that number goes in that cell
    @s.map do |row|
      row.map! do |cell|
        if cell.class == Array
          return false if cell.size == 0
          cell = cell[0] if cell.size == 1
        end
        cell
      end
    end
    self.printy
    return true
  end

  def rule_1
    self.method_printy
    @count[:rule_1] += 1
    changed = 0
    # each row + column can only contain each number once
    # so if any cell is solved, delete that number from the row and column
    [:r, :c].each do |r_or_c|
      @s = @s.transpose if r_or_c == :c
      @s.map!.each_with_index do |row, j|
        # if the row is complete check it fits the clues
        # (bad to do this every time? better than it was before though)
        # if row == row.flatten
        #    return false if check_row_or_col(r_or_c, j) == false
        # end
        solved = row.select { |cell| cell.class == Integer }
        row.map do |cell|
          if cell.class == Array
            if cell.size == 0
              @s = @s.transpose if r_or_c == :c
              return false
            end
            if cell & solved != []
              changed = 1
              cell -= solved
            end
          end
          cell = cell[0] if cell.size == 1
          cell
        end
      end
      @s = @s.transpose if r_or_c == :c
    end
    self.printy
    return true
  end

  def rule_2
    self.method_printy
    @count[:rule_2] += 1
    # if only one cell in a row or column can contain a number then it must go there
    [:r, :c].each do |r_or_c|
      @s = @s.transpose if r_or_c == :c
      @s.map! do |row|
        (1..@d).to_a.each do |n|
          if row.flatten.count(n) == 0
            @s = @s.transpose if r_or_c == :c
            return false
          end
          if (!row.include? n) && (row.flatten.count(n) == 1)
            row[row.find_index{ |cell| cell.class == Array && cell.include?(n) }] = n
          end
        end
        row
      end
      @s = @s.transpose if r_or_c == :c
    end
    self.printy
    return true
  end
  
  def check_row_or_col(r_or_c, i)
    self.method_printy
    # checks a row or column to see if it agrees with the clues

    @s = @s.transpose if r_or_c == :c
    row = @s[i]
    @s = @s.transpose if r_or_c == :c
    # p row
    # p @c[r_or_c][i]

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

  def check_square
    self.method_printy
    @count[:check_square] += 1
    # checks the whole solution to see if it agrees with the clues
    [:r, :c].each do |r_or_c|
      (0..@d-1).each do |i|
        return false if check_row_or_col(r_or_c, i) == false
      end
    end
    self.printy
    true
  end

  def make_a_guess
    self.method_printy
    self.printy
    @count[:make_a_guess] += 1
    count_unsolved = @s.map { |row| row.count { |cell| cell.class == Array } }
    j = count_unsolved.each_with_index.select {|count, index| count > 0}.min[1]
    i = @s[j].each_with_index.find { |cell, k| cell.class == Array }[1]

    @g += [{
      square: Marshal.load(Marshal.dump(@s)),
      j: j,
      i: i,
    }]
    @s[j][i] = @s[j][i][-1]
    self.printy
    return @g[-1]
  end

  def a_guess_was_wrong
    self.method_printy
    @count[:a_guess_was_wrong] += 1
    # self.printy
    last_guess = []
    loop do
      last_guess = @g.pop
      break if last_guess[:square][last_guess[:j]][last_guess[:i]].size >= 2
    end

    @s = Marshal.load(Marshal.dump(last_guess[:square]))
    remaining_options = @s[last_guess[:j]][last_guess[:i]][0..-2]
    if remaining_options.size == 1
      @s[last_guess[:j]][last_guess[:i]] = remaining_options[0]
    else
      @s[last_guess[:j]][last_guess[:i]] = remaining_options
      self.make_a_guess
    end
    @failed = false
    self.printy

  end

  def apply_rules
    # self.printy

    # previous_s = nil
    # while (@s.flatten(2) != @s.flatten(1)) && (@s != previous_s)
    #   previous_s = Marshal.load(Marshal.dump(@s))
    #   if !self.rule_1
    #     @failed = true
    #     return false
    #   end
    #   if !self.rule_2
    #     @failed = true
    #     return false
    #   end
    #   if !self.check_square
    #     @failed = true
    #     return false
    #   end
    #   if !(self.rule_1 && self.rule_2 && self.check_square)
    #     @failed = true
    #     return false
    #   end
    # end

      if !(self.rule_1 && self.rule_2 && self.check_square)
        @failed = true
        return false
      end
    self.printy
    return true
  end

  def solve
    @printy = true

    self.apply_rules
    until @s.flatten(1) == @s.flatten(2) && self.check_square

      if @failed
        self.a_guess_was_wrong
      else
        self.make_a_guess
      end

      self.apply_rules
    end

    @printy = true
    p @count

    return @s

  end

end

def solve_puzzle(clues)
  p = Puzzle.new(clues)
  p.solve
end

# clues1 = [ 3, 2, 2, 3, 2, 1,
#               1, 2, 3, 3, 2, 2,
#               5, 1, 2, 2, 4, 3,
#               3, 2, 1, 2, 2, 4]

# clues2 = [ 0, 0, 0, 2, 2, 0,
#           0, 0, 0, 6, 3, 0,
#           0, 4, 0, 0, 0, 0,
#           4, 4, 0, 3, 0, 0]

# clues3 = [ 0, 3, 0, 5, 3, 4,
#       0, 0, 0, 0, 0, 1,
#       0, 3, 0, 3, 2, 3,
#       3, 2, 0, 3, 1, 0]

# [clues1, clues2, clues3].each do |clues|
#   puts Benchmark.measure { solve_puzzle(clues) }
# end


    clues    = [0, 0, 1, 2,
                0, 2, 0, 0,
                0, 3, 0, 0,
                0, 1, 0, 0]

  puts Benchmark.measure { solve_puzzle(clues) }
