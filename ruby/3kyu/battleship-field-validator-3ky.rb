def validate_battlefield (field)
  field.each{ |row| p row }
  tings = []
  ids = []
  lengths = []
  10.times { tings += [[0]*10] }
  (0..9).each do |j|
    (0..9).each do |i|
      if field[j][i] == 1
        
        neighbours = []
        [[-1,-1],[0,-1],[1,-1],[-1,0]].each do |x, y|
          if ((0..9).include? (j+y)) && ((0..9).include? (i+x))
            neighbours += [tings[j+y][i+x]]
          end
        end
        neighbours = neighbours.uniq - [0]

        case neighbours.size
        when 0
          # start a new block
          id = (ids.size > 0) ? (ids.flatten.max + 1) : 1
          tings[j][i] = id
          ids += [id]
        when 1
          # continue a block
          tings[j][i] = neighbours[0]
        else
          # merge two blocks
          p neighbours
          m = neighbours.min
          tings.map! { |row| row.map! { |c| (neighbours.include? c) ? m : c } }
          ids -= neighbours
          ids += [m]
          tings[j][i] = m
        end
      end
    end
  end
  tings.each{|p| p p }
  # check blocks are confined to a single row or column
  ids.each do |id|
    rows = (tings.map { |row| row.count(id) } - [0]).size
    cols = (tings.transpose.map { |row| row.count(id) } - [0]).size
    if rows > 1 && cols > 1
      return false
    else
      lengths += [[rows, cols].max]
    end
  end
  lengths.sort!
  if lengths == [1,1,1,1,2,2,2,3,3,4]
    return true
  else
    return false
  end
  
end


field = [[1, 0, 0, 0, 0, 1, 1, 0, 0, 0],
         [1, 0, 1, 0, 0, 0, 0, 0, 1, 0],
         [1, 0, 1, 0, 1, 1, 1, 0, 1, 0],
         [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
         [0, 0, 0, 0, 1, 1, 1, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
         [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
         [1, 1, 1, 0, 0, 0, 0, 0, 0, 0]]

p validate_battlefield(field)