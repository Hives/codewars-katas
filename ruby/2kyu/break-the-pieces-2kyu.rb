def break_pieces(shape)
  shape = shape.split(/\n+/)
  blocks = []
  block_ids = []
  solution = []

  # pad lines to length of longest line so we can transpose later
  length = shape.map{ |line| line.size }.max
  shape.map!{ |line| line.ljust(length, " ") }

  shape.each_with_index do |line, j|
    blocks += [[]]
    line.chars.each_with_index do |c, i|

      # if c is " " we're inside a block
      if c == " "

        # get neighbours on previous row and cell to the left
        neighbours = []
        [[-1,-1],[0,-1],[1,-1],[-1,0]].each do |x, y|
            if ((0..blocks.size-1).include? (j+y)) &&
               ((0..blocks[j+y].size-1).include? (i+x))
              neighbours += [blocks[j+y][i+x]]
            end
        end

        neighbours = neighbours.uniq - [0]
        case neighbours.size
        when 0
          # if no non-zero neighbours, start a new block
          id = (block_ids.size > 0) ? (block_ids.flatten.max + 1) : 1
          blocks[-1] += [id]
          block_ids += [[id]]
        when 1
          # if one non-zero neighbour, continue that block
          blocks[-1] += [neighbours[0]]
        else
          # if > 1 non-zero neighbours, register that those blocks are the same
          blocks[-1] += [neighbours.max]
          block_ids.delete_if do |ids|
            if ([ids].flatten & neighbours).empty?
              false
            else
              neighbours = [ids].flatten | neighbours
              true
            end
          end
          block_ids += [neighbours]
        end

      else
        blocks[-1] += [0]
      end
    end
  end

  # ignore blocks which touch the outside
  outside = blocks[0] + blocks[-1] + blocks.transpose[0] + blocks.transpose[-1]
  outside = outside.uniq - [0]
  block_ids.delete_if{ |ids| !(ids & outside).empty? }

  # convert each block into its outline
  block_ids.each do |ids|
    outline = []

    # copy outline from original shape
    shape.each_with_index do |line, j|
      outline += [[]]
      line.chars.each_with_index do |c, i|
        if ids.include? blocks[j][i]
          outline[-1] += [" "]
        else
          neighbours = []
          (-1..1).each do |y|
            (-1..1).each do |x|
              if ((0..blocks.size-1).include? (j+y)) &&
                 ((0..blocks[j+y].size-1).include? (i+x))
                neighbours += [blocks[j+y][i+x]]
              end
            end
          end
          if (ids & neighbours.uniq).empty?
            outline[-1] += [" "]
          else
            outline[-1] += [c]
          end
        end
      end
    end

    # trim blank lines and columns
    outline.delete_if{ |line| line.uniq == [" "] }
    outline = outline.transpose.delete_if{ |line| line.uniq == [" "] }.transpose

    # remove unnecessary crosses
    outline.map!.each_with_index do |line, j|
      line.map!.each_with_index do |c, i|
        if c == "+"
          cross = []

          # get vertical and horizontal neighbours
          [[0,-1],[1,0],[0,1],[-1,0]].each do |x, y|
            if ((0..outline.size-1).include? (j+y)) &&
               ((0..outline[j+y].size-1).include? (i+x))
              cross += [outline[j+y][i+x]]
            else
              cross += [" "]
            end
          end

          # straight vertical
          if (["|", "+"].include? cross [0]) &&
             ([" ", "|"].include? cross [1]) &&
             (["|", "+"].include? cross [2]) &&
             ([" ", "|"].include? cross [3])
            "|"

          # straight horizontal
          elsif ([" ", "-"].include? cross [0]) &&
                (["-", "+"].include? cross [1]) &&
                ([" ", "-"].include? cross [2]) &&
                (["-", "+"].include? cross [3])
            "-"
          else
            "+"

          end
        else
          c
        end
      end
    end

    # tidy up outline
    outline.map! { |line| line.join.rstrip }
    solution += [outline.join("\n")]

  end
  
  solution

end

def print_blocks(blocks)
  blocks.each { |line| puts line.to_s }
  puts "--"
end

def print_solution(solution)
  solution.each { |s| puts "*"; puts s }
end

shapes = [
  ["+------------+",
   "|            |",
   "|            |",
   "|            |",
   "+------+-----+",
   "|      |     |",
   "|      |     |",
   "+------+-----+"].join("\n"),

  ["   +--+",
   "   |  |",
   "+--+  |",
   "|   +-+",
   "+---+  "].join("\n"),

  ["+---+--+-----+",
   "|   |  |     |",
   "|   |  +     |",
   "|   +-+ +----+",
   "+---+ | |    +",
   "|   | | +    |",
   "|   | |      |",
   "+---+-+-+----+"].join("\n"),

  ["+--+   ",
   "|  |   ",
   "|  +--+",
   "|     +",
   "+-----+"].join("\n"),

  ["+-+ +-+",
   "| | | |",
   "| +-+ |",
   "|     |",
   "+-----+"].join("\n"),

  ["+-----------------+",
   "|                 |",
   "|   +-------------+",
   "|   |",
   "|   |",
   "|   |",
   "|   +-------------+",
   "|                 |",
   "|                 |",
   "+-----------------+"].join("\n"),

]

for s in shapes
  puts "************"
  puts s
  print_solution( break_pieces(s) )
end
