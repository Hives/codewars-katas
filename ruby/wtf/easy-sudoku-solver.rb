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
          cell_could_be.size == 1 ? cell_could_be[0] : cell_could_be
        else
          cell
        end
      end
    end

  end

  puts "iterations: #{i}"
  puzzle

end

puzzle = [[0, 0, 6, 1, 0, 0, 0, 0, 8], 
          [0, 8, 0, 0, 9, 0, 0, 3, 0], 
          [2, 0, 0, 0, 0, 5, 4, 0, 0], 
          [4, 0, 0, 0, 0, 1, 8, 0, 0], 
          [0, 3, 0, 0, 7, 0, 0, 4, 0], 
          [0, 0, 7, 9, 0, 0, 0, 0, 3], 
          [0, 0, 8, 4, 0, 0, 0, 0, 6], 
          [0, 2, 0, 0, 5, 0, 0, 8, 0], 
          [1, 0, 0, 0, 0, 2, 5, 0, 0]]

# easy_sudoku_solver(puzzle).each { |row| puts row.sort.to_s }
easy_sudoku_solver(puzzle).each { |row| puts row.to_s }
# puts easy_sudoku_solver(puzzle).to_s
