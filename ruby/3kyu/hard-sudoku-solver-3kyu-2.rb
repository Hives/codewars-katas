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

def easy_sudoku_solver(puzzle)

  previous_iteration = nil

  i = 0
  while (puzzle.flatten(1) != puzzle.flatten(2) || puzzle.flatten.include?(0)) &&
        (puzzle != previous_iteration)

    i += 1
    previous_iteration = Marshal.load(Marshal.dump(puzzle))

    puzzle.map!.each_with_index do |row, y|
      row.map!.each_with_index do |cell, x|
        if cell == 0 || cell.class == Array
          cell_could_be = (1..9).to_a -
                          row - # values in row
                          puzzle.transpose[x] - # values in column
                          puzzle[(y/3)*3, 3].transpose[(x/3)*3, 3].flatten(1) # values in square
          if cell_could_be.size == 0
            # something went wrong!
            return false
          end
          cell_could_be.size == 1 ? cell_could_be[0] : cell_could_be
        else
          cell
        end
      end
    end

  end

  puzzle

end

def backtrack_with_deductions(puzzle)

  solution = Marshal.load(Marshal.dump(puzzle))
  guess_stack = []
  c = SudokuCounter.new

  solution = easy_sudoku_solver(solution)

  while solution == false || solution.flatten(1) != solution.flatten(2)

    if solution == false
      # the last guess was wrong

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
      guess_stack += [{ x: c.x, y: c.y, other_possibilities: solution[c.y][c.x], old_solution: Marshal.load(Marshal.dump(solution)) }]
      solution[c.y][c.x] = guess

    end

    solution = easy_sudoku_solver(solution)

  end
  
  solution
  
end

def solve(puzzle)
  backtrack_with_deductions(puzzle)
end

def print(sudoku)
  puts "-"
  sudoku.each{ |row| puts row.to_s }
  puts "-"
end

puzzle = [
 [9, 0, 0, 0, 8, 0, 0, 0, 1],
 [0, 0, 0, 4, 0, 6, 0, 0, 0],
 [0, 0, 5, 0, 7, 0, 3, 0, 0],
 [0, 6, 0, 0, 0, 0, 0, 4, 0],
 [4, 0, 1, 0, 6, 0, 5, 0, 8],
 [0, 9, 0, 0, 0, 0, 0, 2, 0],
 [0, 0, 7, 0, 3, 0, 2, 0, 0],
 [0, 0, 0, 7, 0, 5, 0, 0, 0],
 [1, 0, 0, 0, 4, 0, 0, 0, 7]]

# puts solve(puzzle).to_s
print(solve(puzzle))
