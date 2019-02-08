class SudokuCounter

  def initialize
    @i = 0
    @j = 0
    @finished = false
  end

  def i
     @i
  end

  def j
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

def test(sol, j, i)
  value = sol[j][i]
  return false if value == 0

  test_row = sol[j].count(value) == 1
  test_col = sol.transpose[i].count(value) == 1
  # test square
  test_sq = sol[3 * (j / 3), 3].transpose[3 * (i / 3), 3].flatten.count(value) == 1

  test_row && test_col && test_sq
end

def solve(puzzle)
  solution = Marshal.load(Marshal.dump(puzzle))

  cells = SudokuCounter.new

  until cells.finished do
    if puzzle[cells.j][cells.i] == 0
      # if the cell is one of the blank ones, start trying numbers
      while (solution[cells.j][cells.i] <= 9 && test(solution, cells.j, cells.i) == false)
        solution[cells.j][cells.i] += 1
      end
      if solution[cells.j][cells.i] > 9
        # the solution has failed, reset the cell, go to the previous cell which was not a given, and increment it by 1
        solution[cells.j][cells.i] = 0
        begin
          cells.prev
        end until puzzle[cells.j][cells.i] == 0
        solution[cells.j][cells.i] += 1
      else
        # if the solution is ok for this cell, go on to the next one
        cells.next
      end
    else
      # if the cell is one of the givens, skip it
      cells.next
    end
  end

  solution
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

puts solve(puzzle).to_s
