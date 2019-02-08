class SudokuCounter

  def initialize
    @i = 0
    @j = 0
    @finished = false
  end

  def reset
    @i = 0
    @j = 0
    @finished = false
  end

  def x
     @i
  end

  def y
     @j
  end

  def next
    if @i == 8
      if @j == 8
        @finished = true
      else
        @i = 0; @j += 1
      end
    else
      @i += 1
    end
  end

  def prev
    @finished = false if @i == 8 && @j == 8
    if @i == 0
      if @j == 0
        # wtf
      else
        @i = 8; @j -= 1
      end
    else
      @i -= 1
    end
  end

  def finished
    @finished
  end

end

def rule(puzzle)
  puzzle.each do |row|
    (1..9).each do |n|
      if !row.include? n
        if row.count { |cell| cell.class == Array && cell.include?(n) } == 1
          row[row.find_index { |cell| cell.class == Array && cell.include?(n) } ] = n
        end
      end
    end
  end
  puzzle
end
#a = [[0,1,2,3,4,5],
#     [[2,3],[2,3],[2,3],[1,2,3]]]
#puts rule(a).to_s

def apply_the_rules(puzzle)

  previous_iteration = nil
  while (puzzle.flatten(1) != puzzle.flatten(2) || puzzle.flatten.include?(0)) &&
        (puzzle != previous_iteration)

    previous_iteration = Marshal.load(Marshal.dump(puzzle))

    # cell can't be same as any other cell in group
    puzzle.map!.each_with_index do |row, y|
      row.map!.each_with_index do |cell, x|
        if cell == 0 || cell.class == Array
          cell_could_be = (1..9).to_a -
                          row - # values in row
                          puzzle.transpose[x] - # values in column
                          puzzle[(y/3)*3, 3].transpose[(x/3)*3, 3].flatten(1) # values in square
          # if cell_could be is empty then the grid has no solution
          return false if cell_could_be.size == 0
          cell_could_be.size == 1 ? cell_could_be[0] : cell_could_be
        else
          cell
        end
      end
    end
  end

  previous_iteration = nil
  while (puzzle.flatten(1) != puzzle.flatten(2) || puzzle.flatten.include?(0)) &&
        (puzzle != previous_iteration)
    
    previous_iteration = Marshal.load(Marshal.dump(puzzle))
    
    ## if a number can only go in one cell in a group, then it must go there
    # apply rule to rows:
    puzzle = rule(puzzle)
    # apply rule to columns:
    #puzzle = puzzle.transpose
    #puzzle = rule(puzzle)
    #puzzle = puzzle.transpose

  end

  puzzle

end

def backtrack_with_deductions(puzzle, depth)

  solution = Marshal.load(Marshal.dump(puzzle))
  guess_stack = []
  c = SudokuCounter.new

  solution = apply_the_rules(solution)

  iterate = 0
  while solution == false || solution.flatten(1) != solution.flatten(2)

    if solution == false
      # last input to apply_the_rules had no solution
      # puts "last guess failed"

      if guess_stack.size == 0
        # no more guesses on the stack means we were given a grid with no solution
        return false
      end

      last_guess = guess_stack[-1]
      # reset the solution
      solution = Marshal.load(Marshal.dump(last_guess[:old_solution]))
      # try the next possbility
      solution[last_guess[:y]][last_guess[:x]] = last_guess[:other_possibilities].pop
      if last_guess[:other_possibilities].size == 0
        # no other options left for this cell, so can delete this guess from the stack
        guess_stack.pop
      end

    else
      # current guess (if any) hasn't proved wrong but we're stuck, so make (another) guess
  
      # find a cell with the shortest list of possibilities
      i = 2
      c.reset
      while !(solution[c.y][c.x].class == Array && solution[c.y][c.x].size == i) &&
            i < 10
        if c.finished
          i += 1
          c.reset
        else
          c.next
        end
      end

      guess = solution[c.y][c.x].pop
      guess_stack += [{ x: c.x,
                        y: c.y,
                        guess: guess,
                        other_possibilities: Marshal.load(Marshal.dump(solution[c.y][c.x])),
                        old_solution: Marshal.load(Marshal.dump(solution)) }]
      solution[c.y][c.x] = guess

    end

    # puts "making a guess #{iterate} (depth = #{depth})"
    # print solution
    iterate += 1

    solution = apply_the_rules(solution)

  end
  
  # we should have a working solution now, which is all we need to know if
  # we're deeper than the first level
  # puts "SOLUTION FOUND"
  return true if depth > 0

  # check if there are any guesses on the stack
  # if yes call this function again on the last guess
  while guess_stack.size > 0
    last_guess = guess_stack[0]
    alternative_guess_grid = Marshal.load(Marshal.dump(guess_stack[0][:old_solution]))
    alternative_guess_grid[last_guess[:y]][last_guess[:x]] = last_guess[:other_possibilities].pop

    guess_stack.shift if last_guess[:other_possibilities].size == 0

    test_alternative = backtrack_with_deductions(alternative_guess_grid, depth + 1)

    raise "Multiple solutions exist" if test_alternative != false

  end
  
  solution
  
end

def sanity_check(puzzle)
  raise "Wrong number of rows" if puzzle.size != 9

  puzzle.each_with_index do |row, j|
    raise "Row was the wrong size" if row.size != 9
    row.each_with_index do |cell, i|
      raise "Cell #{i+1},#{j+1} invalid" if !(0..9).to_a.include? cell
    end
  end

  raise "At least 17 givens required" if (puzzle.flatten - [0]).size < 17

  puzzle.each { |row| (1..9).each { |n| raise "Duplicate number in row" if row.count(n) > 1 } }
  puzzle.transpose.each { |row| (1..9).each { |n| raise "Duplicate number in column" if row.count(n) > 1 } }
  (0..2).each do |y|
    (0..2).each do |x|
      square = puzzle[3 * y, 3].transpose[3 * x, 3].flatten
      (1..9).each { |n| raise "Duplicate number in square" if square.count(n) > 1}
    end
  end

end

def sudoku_solver(puzzle)
  sanity_check(puzzle)
  solution = backtrack_with_deductions(puzzle, 0)
  raise "No solution found" if solution == false
  solution
end

def print(sudoku)
  puts "-"
  sudoku.each{ |row| puts row.to_s }
  puts "-"
end

def print_guesses(guesses)
  guesses_copy = Marshal.load(Marshal.dump(guesses))
  puts "--"
  while guesses_copy.size > 0
    g = guesses_copy.pop
    puts "x: #{g[:x]+1}, y: #{g[:y] + 1}, guess: #{g[:guess]}, other possibilities: #{g[:other_possibilities]}"
    g[:old_solution].each{ |row| puts row.to_s }
    puts "--"
  end
end

# "hard" puzzle
puzzle1 = [[5,3,0,0,7,0,0,0,0],
          [6,0,0,1,9,5,0,0,0],
          [0,9,8,0,0,0,0,6,0],
          [8,0,0,0,6,0,0,0,3],
          [4,0,0,8,0,3,0,0,1],
          [7,0,0,0,2,0,0,0,6],
          [0,6,0,0,0,0,2,8,0],
          [0,0,0,4,1,9,0,0,5],
          [0,0,0,0,8,0,0,7,9]]

# puzzle with guesses
puzzle2 = [[3, 4, 6, 1, 2, 7, 9, 5, 8],
          [7, 8, [1], 6, 9, 4, [1, 2], 3, [1, 2]],
          [2, [1, 9], [1, 9], [3, 8], [3, 8], 5, 4, [1, 6, 7], [1, 7]],
          [4, [5, 6, 9], [2, 5, 9], [2, 3, 5], [3, 6], 1, 8, [2, 6, 7, 9], [2, 5, 7, 9]],
          [[5, 6, 8, 9], 3, [1, 2, 5, 9], [2, 5, 8], 7, [6, 8], [1, 2, 6], 4, [1, 2, 5, 9]],
          [[5, 6, 8], [1, 5, 6], 7, 9, [4, 6, 8], [6, 8], [1, 2, 6], [1, 2, 6], 3],
          [[5, 9], [5, 7, 9], 8, 4, [1, 3], [3, 9], [1, 2, 3, 7], [1, 2, 7, 9], 6],
          [[6, 9], 2, [3, 4, 9], [3, 7], 5, [3, 6, 9], [1, 3, 7], 8, [1, 4, 7, 9]],
          [1, [6, 7, 9], [3, 4, 9], [3, 7, 8], [3, 6, 8], 2, 5, [7, 9], [4, 7, 9]]]

# insoluble puzzle
puzzle3 = [[5, 1, 6, 8, 4, 9, 7, 3, 2],
          [3, 0, 7, 6, 0, 5, 0, 0, 0],
          [8, 0, 9, 7, 0, 0, 0, 6, 5],
          [1, 3, 5, 0, 6, 0, 9, 0, 7],
          [4, 7, 2, 5, 9, 1, 0, 0, 6],
          [9, 6, 8, 3, 7, 0, 0, 5, 0],
          [2, 5, 3, 1, 8, 6, 0, 7, 4],
          [2, 5, 3, 1, 8, 6, 0, 7, 4],
          [6, 8, 4, 2, 0, 7, 5, 0, 0],
          [7, 9, 1, 0, 5, 0, 6, 0, 8]]

# hard puzzle
puzzle4 = [
 [9, 0, 0, 0, 8, 0, 0, 0, 1],
 [0, 0, 0, 4, 0, 6, 0, 0, 0],
 [0, 0, 5, 0, 7, 0, 3, 0, 0],
 [0, 6, 0, 0, 0, 0, 0, 4, 0],
 [4, 0, 1, 0, 6, 0, 5, 0, 8],
 [0, 9, 0, 0, 0, 0, 0, 2, 0],
 [0, 0, 7, 0, 3, 0, 2, 0, 0],
 [0, 0, 0, 7, 0, 5, 0, 0, 0],
 [1, 0, 0, 0, 4, 0, 0, 0, 7]]

puzzle5 = [[[3, 5, 7, 9], [4, 5, 7, 9], 6, 1, [2, 3, 4], [3, 4, 7], [2, 7, 9], [2, 5, 7, 9], 8],
          [[5], 8, [1, 4, 5], [2, 6, 7], 9, [4, 6, 7], [1, 2, 6, 7], 3, [1, 2, 5, 7]],
          [2, [1, 7, 9], [1, 3, 9], [3, 6, 7, 8], [3, 6, 8], 5, 4, [1, 6, 7, 9], [1, 7, 9]],
          [4, [5, 6, 9], [2, 5, 9], [2, 3, 5, 6], [2, 3, 6], 1, 8, [2, 5, 6, 7, 9], [2, 5, 7, 9]],
          [[5, 6, 8, 9], 3, [1, 2, 5, 9], [2, 5, 6, 8], 7, [6, 8], [1, 2, 6, 9], 4, [1, 2, 5, 9]],
          [[5, 6, 8], [1, 5, 6], 7, 9, [2, 4, 6, 8], [4, 6, 8], [1, 2, 6], [1, 2, 5, 6], 3],
          [[3, 5, 7, 9], [5, 7, 9], 8, 4, [1, 3], [3, 7, 9], [1, 2, 3, 7, 9], [1, 2, 7, 9], 6],
          [[3, 6, 7, 9], 2, [3, 4, 9], [3, 6, 7], 5, [3, 6, 7, 9], [1, 3, 7, 9], 8, [1, 4, 7, 9]],
          [1, [4, 6, 7, 9], [3, 4, 9], [3, 6, 7, 8], [3, 6, 8], 2, 5, [7, 9], [4, 7, 9]]]

puzzle6 = [[[3, 5, 7, 9], [4, 5, 7, 9], 6, 1, [2, 3, 4], [3, 4, 7], [2, 7, 9], [2, 5, 7, 9], 8],
          [5, 8, [1, 4, 5], [2, 6, 7], 9, [4, 6, 7], [1, 2, 6, 7], 3, [1, 2, 5, 7]],
          [2, [1, 7, 9], [1, 3, 9], [3, 6, 7, 8], [3, 6, 8], 5, 4, [1, 6, 7, 9], [1, 7, 9]],
          [4, [5, 6, 9], [2, 5, 9], [2, 3, 5, 6], [2, 3, 6], 1, 8, [2, 5, 6, 7, 9], [2, 5, 7, 9]],
          [[5, 6, 8, 9], 3, [1, 2, 5, 9], [2, 5, 6, 8], 7, [6, 8], [1, 2, 6, 9], 4, [1, 2, 5, 9]],
          [[5, 6, 8], [1, 5, 6], 7, 9, [2, 4, 6, 8], [4, 6, 8], [1, 2, 6], [1, 2, 5, 6], 3],
          [[3, 5, 7, 9], [5, 7, 9], 8, 4, [1, 3], [3, 7, 9], [1, 2, 3, 7, 9], [1, 2, 7, 9], 6],
          [[3, 6, 7, 9], 2, [3, 4, 9], [3, 6, 7], 5, [3, 6, 7, 9], [1, 3, 7, 9], 8, [1, 4, 7, 9]],
          [1, [4, 6, 7, 9], [3, 4, 9], [3, 6, 7, 8], [3, 6, 8], 2, 5, [7, 9], [4, 7, 9]]]

# puzzle with two solutions
puzzle7 = [[2, 9, 5, 7, 4, 3, 8, 6 ,1],
          [4, 3, 1, 8, 6, 5, 9, 0, 0],
          [8, 7, 6, 1, 9, 2, 5, 4, 3],
          [3, 8, 7, 4, 5, 9, 2, 1, 6],
          [6, 1, 2, 3, 8, 7, 4, 9, 5],
          [5, 4, 9, 2, 1, 6, 7, 3, 8],
          [7, 6, 3, 5, 2, 4, 1, 8, 9],
          [9, 2, 8, 6, 7, 1, 3, 5, 4],
          [1, 5, 4, 9, 3, 8, 6, 0, 0]]

# easy puzzle
puzzle8 = [[0, 9, 6, 5, 0, 4, 0, 7, 1],
[0, 2, 0, 1, 0, 0, 0, 0, 0],
[0, 1, 4, 0, 9, 0, 6, 2, 3],
[0, 0, 3, 0, 6, 0, 0, 8, 0],
[0, 0, 8, 0, 5, 0, 4, 0, 0],
[9, 0, 0, 4, 0, 0, 0, 0, 5],
[7, 0, 0, 0, 0, 9, 0, 0, 0],
[0, 0, 1, 0, 7, 5, 3, 4, 9],
[2, 3, 0, 0, 4, 8, 1, 0, 7]]

puzzle9 = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0], 
           [0, 0, 0, 0, 0, 0, 0, 0, 0]]

# random puzzle that's failing
puzzle10 = [[5, 0, 0, 0, 0, 0, 0, 8, 0],
[7, 0, 0, 0, 0, 0, 0, 0, 0],
[0, 0, 0, 0, 3, 0, 0, 0, 9],
[0, 0, 0, 7, 0, 0, 2, 0, 0],
[0, 3, 0, 0, 0, 0, 0, 0, 8],
[4, 9, 0, 0, 0, 0, 0, 0, 0],
[0, 0, 0, 0, 0, 0, 0, 0, 0],
[0, 1, 8, 0, 9, 0, 0, 0, 0],
[0, 0, 0, 0, 0, 2, 7, 5, 0]]

print(sudoku_solver(puzzle10))
