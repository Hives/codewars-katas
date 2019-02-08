def break_evil_pieces(shape)
  return [] if !shape.include? "+"
  @shape = shape.split(/\n+/)
  blocks = []
  block_ids = []
  block_rows = {}
  block_cols = {}
  outside_blocks = []
  solution = []
  @added_rows = []
  @added_cols = []

  def trans
    # transposes shape, swapping "-" and "|" as appropriate
    @shape.map! do |row|
      row.map do |c|
        if c == "-"
          "|"
        elsif c == "|"
          "-"
        else
          c
        end
      end
    end
    @shape = @shape.transpose
  end

  def expand_vert(r_or_c)
    shape_expanded = [@shape[0]]
    @shape.each_cons(2) do |prev_row, row|

      zipped_rows = prev_row.zip(row)
      if zipped_rows & [["+","-"],["-","+"],["+","+"],["-","-"]] != []
        expansion_line = []
        zipped_rows.each do |prev_row_cell, row_cell|
          if ("+|".include? row_cell) &&
              ("+|".include? prev_row_cell)
            expansion_line += ["|"]
          else
            expansion_line += [" "]
          end
        end
        shape_expanded += [expansion_line]
        r_or_c == :r ?
          @added_rows += [shape_expanded.size - 1] :
          @added_cols += [shape_expanded.size - 1]
      end
      
      shape_expanded += [row]

    end
    @shape = shape_expanded
  end

  def printy(shape)
    shape.each { |row| puts row.join.gsub(" ", ".") }
  end
  
  # pad lines to length of longest line so we can transpose later
  length = @shape.map{ |line| line.size }.max
  @shape.map!{ |line| line.ljust(length, " ").split("") }

  # trim blank rows and columns from edges
  [:r, :c].each do |r_or_c|
    @shape = @shape.transpose if r_or_c == :c
    @shape.pop while @shape[-1].uniq == [" "]
    @shape.shift while @shape[0].uniq == [" "]
    @shape = @shape.transpose if r_or_c == :c
  end

  # expand rows and columns
  [:r, :c].each do |r_or_c|
    trans if r_or_c == :c
    expand_vert(r_or_c)
    trans if r_or_c == :c
  end

  # flood-fill spaces with blocks, also register which rows and columns the
  # blocks span, in block_rows and block_cols
  @shape.each_with_index do |row, j|
    blocks += [[]]
    row.each_with_index do |c, i|

      # if c is " " we're inside a block
      if c == " "

        # get neighbours on previous row and cell to the left
        neighbours = []
        [[-1,-1],[0,-1],[1,-1],[-1,0]].each do |x, y|
            if blocks[j+y] && blocks[j+y][i+x]
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
          block_rows[id] = [j]
          block_cols[id] = [i]
        when 1
          # if one non-zero neighbour, continue that block
          id = neighbours[0]
          blocks[-1] += [id]
          block_rows[id] = block_rows[id] | [j]
          block_cols[id] = block_cols[id] | [i]
        else
          # if > 1 non-zero neighbours, register that those blocks are the same
          id = neighbours.max
          blocks[-1] += [id]
          block_rows[id] = block_rows[id] | [j]
          block_cols[id] = block_cols[id] | [i]
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
        if j == 0 || j == @shape.size - 1 || i == 0 || i == row.size - 1
          outside_blocks = outside_blocks | [id]
        end

      else
        blocks[-1] += [0]
      end
    end
  end

  block_ids.reverse! # remember to get rid of this

  if blocks.size > 0
    # ignore blocks which touch the outside
    block_ids.delete_if{ |ids| !(ids & outside_blocks).empty? }

    # copy outline of each block from @shape
    block_ids.each do |ids|
      outline = []
      crosses = []

      # copy outline from original shape
      row_nos = []
      ids.each { |id| row_nos = row_nos | block_rows[id] }
      first_row = row_nos.min - 1
      last_row = row_nos.max + 1
      row_nos += [last_row]; row_nos.unshift(first_row)
      row_nos.sort!
      col_nos = []
      ids.each { |id| col_nos = col_nos | block_cols[id] }
      first_col = col_nos.min - 1
      last_col = col_nos.max + 1
      col_nos += [last_col]; col_nos.unshift(first_col)
      col_nos.sort!

      row_nos.each do |j|
        outline += [[]]
        if row_nos.include? j
          col_nos.each do |i|
            c = @shape[j][i]
            if ids.include? blocks[j][i]
              # inside a block
              outline[-1] += [" "]
            else
              neighbours = []
              (-1..1).each do |y|
                (-1..1).each do |x|
                  if blocks[j+y] && blocks[j+y][i+x]
                    neighbours += [blocks[j+y][i+x]]
                  end
                end
              end
              if (ids & neighbours.uniq).empty?
                outline[-1] += [" "]
              else
                crosses += [{i: i - first_col, j: j - first_row}] if c == "+"
                outline[-1] += [c]
              end
            end
          end
        end
      end

      # remove unnecessary crosses
      crosses.each do |cross|
        neighbours = []
   
        [[0,-1],[1,0],[0,1],[-1,0]].each do |x, y|
          if cross[:j]+y >= 0 && cross[:j]+y < outline.size &&
             cross[:i]+x >= 0 && cross[:i]+x < outline[0].size
            neighbours += [outline[cross[:j]+y][cross[:i]+x]]
          else
            neighbours += [" "]
          end
        end

        if (["|", "+"].include? neighbours [0]) &&
           ([" ", "|"].include? neighbours [1]) &&
           (["|", "+"].include? neighbours [2]) &&
           ([" ", "|"].include? neighbours [3])
          # straight vertical
          outline[cross[:j]][cross[:i]] = "|"
        elsif ([" ", "-"].include? neighbours [0]) &&
              (["-", "+"].include? neighbours [1]) &&
              ([" ", "-"].include? neighbours [2]) &&
              (["-", "+"].include? neighbours [3])
          # straight horizontal
          outline[cross[:j]][cross[:i]] = "-"
        end

      end

      (@added_rows).reverse.each { |j| outline.delete_at( j - first_row ) if j > first_row && j < last_row }
      outline = outline.transpose
      (@added_cols).reverse.each { |i| outline.delete_at( i - first_col) if i > first_col && i < last_col }
      outline = outline.transpose

      # tidy up outline
      outline.map! { |line| line.join.rstrip }
      solution += [outline.join("\n")]

    end
  
    solution
  else
    []
  end

end

def print_blocks(blocks)
  blocks.each { |line| puts line.to_s }
  puts "--"
end

def print_solution(solution)
  solution.each { |s| puts " "; puts s }
end

require 'benchmark'

# shapes = [
#   # l
#   #  "+------+-----+"].join("\n"),

#   # ["   +--+",
#   #  "   |  |",
#   #  "+--+  |",
#   #  "|   +-+",
#   #  "+---+  "].join("\n"),

#   # ["+---+--+-----+",
#   #  "|   |  |     |",
#   #  "|   |  +     |",
#   #  "|   +-+ +----+",
#   #  "+---+ | |    +",
#   #  "|   | | +    |",
#   #  "|   | |      |",
#   #  "+---+-+-+----+"].join("\n"),

#   # ["+--+   ",
#   #  "|  |   ",
#   #  "|  +--+",
#   #  "|     +",
#   #  "+-----+"].join("\n"),

#   # ["+-+ +-+",
#   #  "| | | |",
#   #  "| +-+ |",
#   #  "|     |",
#   #  "+-----+"].join("\n"),

#   # ["+-----------------+",
#   #  "|                 |",
#   #  "|   +-------------+",
#   #  "|   |",
#   #  "|   |",
#   #  "|   |",
#   #  "|   +-------------+",
#   #  "|                 |",
#   #  "|                 |",
#   #  "+-----------------+"].join("\n"),

#   """
#   +------------+
#   |            |
#   |            |
#   |            |
#   +------++----+
#   |      ||    |
#   |      ||    |
#   +------++----+
#   """,

#   ""

# ]

shapes = [
  "                          \n  ++ ++ ++                \n  || || ||                \n  || || ||                \n +++-++-++--------------+ \n |                      | \n ++-++-++---------------+ \n || || ||                 \n || || ||                 \n ++ ++ ++                 \n                          ",
  "+----+\n|    |\n|    +----+\n|    |    |\n|    +---+|\n|    |   ||\n|+---+   ||\n||       ||\n|+-------+|\n+---------+",
  "             \n +----+      \n |    |      \n |    +----+ \n |    |    | \n |    +---+| \n |    |   || \n |+---+   || \n ||       || \n |+-------+| \n +---------+ \n             ",
  "+---+  +----+\n|   |  |    |\n|   +--+    |\n|      |    |\n|   +--+    |\n|   |  |    |\n|   |  +---+|\n|   |      ||\n|   +------+|\n+-----------+",
  "               \n +---+  +----+ \n |   |  |    | \n |   +--+    | \n |      |    | \n |   +--+    | \n |   |  |    | \n |   |  +---+| \n |   |      || \n |   +------+| \n +-----------+ \n               ",
  "+----------------------+\n|+----++--------++----+|\n||    ||        ||    ||\n||    ||        ||    ||\n|+----+|        |+----+|\n+------+        +------+",
  "                          \n +----------------------+ \n |+----++--------++----+| \n ||    ||        ||    || \n ||    ||        ||    || \n |+----+|        |+----+| \n +------+        +------+ \n                          ",
  "++++++++++++\n++--++++--++\n++++++++++++\n+++------+++\n++|++++++|++\n++++++++++++",
  "              \n ++++++++++++ \n ++--++++--++ \n ++++++++++++ \n +++------+++ \n ++|++++++|++ \n ++++++++++++ \n              ",
  "  +-----------------+\n  |+--------++-----+|\n  ||        ++     ||\n  |+--------+|     ||\n+++----------+     ||\n|++----------------+|\n|||+----------------+\n||||\n|||+------+\n||+-------+\n|+--------+\n+---------+\n\n+-----------+\n|+++------++|\n||++      ++|\n||        |||\n|+--------+||\n+----------+|\n+-----------+",
  "                       \n   +-----------------+ \n   |+--------++-----+| \n   ||        ++     || \n   |+--------+|     || \n +++----------+     || \n |++----------------+| \n |||+----------------+ \n ||||                  \n |||+------+           \n ||+-------+           \n |+--------+           \n +---------+           \n                       \n +-----------+         \n |+++------++|         \n ||++      ++|         \n ||        |||         \n |+--------+||         \n +----------+|         \n +-----------+         \n                       ",
  "+--------+-+----------------+-+----------------+-+--------+\n  |        +-+                +-+                | |        |\n  |    +------+                                  | |        |\n  |    |+----+|                             +----+ |        |\n  |    ||+--+||                             |+-----+    ++  |\n  |    |||++|||                             ||          ||  |\n  ++   |||++|||      ++                 ++  ||  +-------+| ++\n  ||   |||+-+||      ||                 ||  ||  |     +--+ ||\n  ++   ||+---+|      ++                 ++  ||  |     +---+++\n  |    |+-++--+                             ||  +--------+| |\n  |+---+--+|                                |+-----------+| |\n  |+-------+                                +----+ +------+ |\n  |                                              | |        |\n  |        +-+                +-+                | |        |\n  |        +-+                +-+                +-+        |\n  |                     +-----+ |    ++    +-----+ |    ++  |\n  |                     +-++----+    ++    +-++----+    ++  |\n  |                       ++                 ++             |\n  |                       ||                 ||             |\n  ++                 ++   |+-------------+   |+-------------+\n  ||                 ||   |              |   |              |\n  ++                 ++   +---+ +--------+   +---+ +--------+\n  |                           | |                | |        |\n  |                           | |                | |        |\n  |                           | |                | |        |\n  |                           | |                | |        |\n  |        +-+                | |                | |        |\n  |        | |                +-+                | |        |\n  |        | |                                   | |        |\n  |        | |                                   | +-----+  |\n  |      +-+ +-+                                 |    +-+|  |\n  |      |     |             +----+              +-+  | ||  |\n  +------+     +------+      |+--+|  ++-------+    +--+ |+--+\n  |                   |      ||++||  ||       +--+      |   |\n  +-------------------+      ||++||  ++------+   +---+  +---+\n  |                          |+--+|          |       |      |\n  |                          +----+          +---+ +-+      |\n  |                                              | |        |\n  |                                              | |        |\n  |        +-+                +-+                | |        |\n  |        +-+                | |                +-+        |\n  |                           | |          +-----+ |    ++  |\n  |                      +----+ |          +-++----+    ++  |\n  |                      |+-----+    ++      ++             |\n  |                      ||          ||      ||             |\n  +-------------------+  ||  +-------+| ++   |+-------------+\n  |                   |  ||  |     +--+ ||   |              |\n  +------+     +------+  ||  |     +---+++   +---+ +--------+\n  |      |     |         ||  +--------+|         | |        |\n  |      +-+ +-+         |+-----------+|         | |        |\n  |        | |           +----+ +------+         | |        |\n  |        | |                | |                | |        |\n  |        | |                | |                | |        |\n  |        | |                +-+                +-+        |\n  |        | |                               +------+       |\n  |        | +-----+                         |+----+|       |\n  |        |    +-+|                         ||+--+||       |\n  |        +-+  | ||         +----+          |||++|||       |\n  +-----+    +--+ |+--+      |+--+|  ++--+   |||++|||      ++\n  |     +--+      |   |      ||++||  ||  |   |||+-+||      ||\n  +----+   +---+  +---+      ||++||  ++--+   ||+---+|      ++\n  |    |       |             |+--+|          |+-++--+       |\n  |    +---+ +-+             +----+      +---+--+|          |\n  |        | |                           +-------+          |\n  |        | |                                              |\n  |        | |                +-+                +-+        |\n  +--------+-+----------------+-+----------------+-+--------+"
]
puts Benchmark.measure {
  100.times do
    for s in shapes
      # puts s
      break_evil_pieces(s)
      # puts shapes[8]
      # print_solution ( break_evil_pieces(shapes[0]) )
    end
  end
}
