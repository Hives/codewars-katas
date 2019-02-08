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

  def rule_0
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
    return true
  end

  def rule_1
    # each row + column can only contain each number once
    # so if any cell is solved, delete that number from the row and column
    [:r, :c].each do |r_or_c|
      @s = @s.transpose if r_or_c == :c
      @s.map! do |row|
        solved = row.select { |cell| cell.class == Integer }
        row.map do |cell|
          if cell.class == Array
            if cell.size == 0
              @s = @s.transpose if r_or_c == :c
              return false
            end
            cell -= solved
          end
          cell = cell[0] if cell.size == 1
          cell
        end
      end
      @s = @s.transpose if r_or_c == :c
    end
    return true
  end

  def rule_2
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
    return true
  end
  
  def check_row_or_col(r_or_c, i)
    # checks a row or column to see if it agrees with the clues

    @s = @s.transpose if r_or_c == :c
    row = @s[i]
    @s = @s.transpose if r_or_c == :c

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
            return false 
          end
        end
      end

    end

    return true

  end

  def check_square
    # checks the whole solution to see if it agrees with the clues
    [:r, :c].each do |r_or_c|
      (0..@d-1).each do |i|
        return false if check_row_or_col(r_or_c, i) == false
      end
    end
    true
  end

  def make_a_guess
    count_unsolved = @s.map { |row| row.count { |cell| cell.class == Array } }
    j = count_unsolved.each_with_index.select {|count, index| count > 0}.min[1]
    i = @s[j].each_with_index.find { |cell, k| cell.class == Array }[1]

    @g += [{
      square: Marshal.load(Marshal.dump(@s)),
      j: j,
      i: i,
    }]
    @s[j][i] = @s[j][i][-1]
    # self.printy
    return @g[-1]
  end

  def a_guess_was_wrong
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
    # self.printy

  end

  def apply_rules
    # self.printy
    previous_s = nil
    while (@s.flatten(2) != @s.flatten(1)) && (@s != previous_s)
      previous_s = Marshal.load(Marshal.dump(@s))
      if !self.rule_1
        @failed = true
        return false
      end
      if !self.rule_2
        @failed = true
        return false
      end
      if !self.check_square
        # self.printy
        @failed = true
        return false
      end
      # if !(self.rule_1 && self.rule_2 && self.check_square)
      #   @failed = true
      #   return false
      # end
    end
    # self.printy
    return true
  end

  def solve

    self.apply_rules
      until @s.flatten(1) == @s.flatten(2) && self.check_square

        if @failed
          self.a_guess_was_wrong
        else
          self.make_a_guess
        end

        self.apply_rules
      end

    return @s

  end

end

def solve_puzzle(clues)
  p = Puzzle.new(clues)
  p.solve
end

clues = [ 3, 2, 2, 3, 2, 1,
              1, 2, 3, 3, 2, 2,
              5, 1, 2, 2, 4, 3,
              3, 2, 1, 2, 2, 4]

puts Benchmark.measure { solve_puzzle(clues) }
