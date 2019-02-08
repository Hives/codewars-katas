def break_evil_pieces(shape)
  return [] if !shape.include? "+"
  @shape = shape.split(/\n+/)
  blocks = []
  block_ids = []
  solution = []
  @added_rows = []
  @added_cols = []

  def trans
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

  [:r, :c].each do |r_or_c|
    trans if r_or_c == :c
    expand_vert(r_or_c)
    trans if r_or_c == :c
  end

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

  if blocks.size > 0
    # ignore blocks which touch the outside
    outside = blocks[0] + blocks[-1] + blocks.transpose[0] + blocks.transpose[-1]
    outside = outside.uniq - [0]
    block_ids.delete_if{ |ids| !(ids & outside).empty? }

    # convert each block into its outline
    block_ids.each do |ids|
      outline = []
      crosses = []

      # copy outline from original shape
      @shape.each_with_index do |row, j|
        outline += [[]]
        row.each_with_index do |c, i|
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
              crosses += [{i: i, j: j}] if c == "+"
              outline[-1] += [c]
            end
          end
        end
      end

      # remove unnecessary crosses
      crosses.each do |cross|
        neighbours = []
   
        [[0,-1],[1,0],[0,1],[-1,0]].each do |x, y|
          if outline[cross[:j]+y] && outline[cross[:j]+y][cross[:i]+x]
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

      [:r, :c].each do |r_or_c|
        outline = outline.transpose if r_or_c == :c
        rows_to_delete = r_or_c == :r ? @added_rows : @added_cols
        rows_to_delete.reverse.each { |j| outline.delete_at(j) }
        outline = outline.transpose if r_or_c == :c
      end

      # trim blank lines and columns
      outline.delete_if{ |line| line.uniq == [" "] }
      outline = outline.transpose.delete_if{ |line| line.uniq == [" "] }.transpose
 
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
  # "+----+\n|    |\n|    +----+\n|    |    |\n|    +---+|\n|    |   ||\n|+---+   ||\n||       ||\n|+-------+|\n+---------+",
  # "             \n +----+      \n |    |      \n |    +----+ \n |    |    | \n |    +---+| \n |    |   || \n |+---+   || \n ||       || \n |+-------+| \n +---------+ \n             ",
  # "+---+  +----+\n|   |  |    |\n|   +--+    |\n|      |    |\n|   +--+    |\n|   |  |    |\n|   |  +---+|\n|   |      ||\n|   +------+|\n+-----------+",
  # "               \n +---+  +----+ \n |   |  |    | \n |   +--+    | \n |      |    | \n |   +--+    | \n |   |  |    | \n |   |  +---+| \n |   |      || \n |   +------+| \n +-----------+ \n               ",
  # "+----------------------+\n|+----++--------++----+|\n||    ||        ||    ||\n||    ||        ||    ||\n|+----+|        |+----+|\n+------+        +------+",
  # "                          \n +----------------------+ \n |+----++--------++----+| \n ||    ||        ||    || \n ||    ||        ||    || \n |+----+|        |+----+| \n +------+        +------+ \n                          ",
  # "++++++++++++\n++--++++--++\n++++++++++++\n+++------+++\n++|++++++|++\n++++++++++++",
  # "              \n ++++++++++++ \n ++--++++--++ \n ++++++++++++ \n +++------+++ \n ++|++++++|++ \n ++++++++++++ \n              ",
  # "  +-----------------+\n  |+--------++-----+|\n  ||        ++     ||\n  |+--------+|     ||\n+++----------+     ||\n|++----------------+|\n|||+----------------+\n||||\n|||+------+\n||+-------+\n|+--------+\n+---------+\n\n+-----------+\n|+++------++|\n||++      ++|\n||        |||\n|+--------+||\n+----------+|\n+-----------+",
  # "                       \n   +-----------------+ \n   |+--------++-----+| \n   ||        ++     || \n   |+--------+|     || \n +++----------+     || \n |++----------------+| \n |||+----------------+ \n ||||                  \n |||+------+           \n ||+-------+           \n |+--------+           \n +---------+           \n                       \n +-----------+         \n |+++------++|         \n ||++      ++|         \n ||        |||         \n |+--------+||         \n +----------+|         \n +-----------+         \n                       "
  "+--------+-+----------------+-+----------------+-+--------+\n  |        +-+                +-+                | |        |\n  |    +------+                                  | |        |\n  |    |+----+|                             +----+ |        |\n  |    ||+--+||                             |+-----+    ++  |\n  |    |||++|||                             ||          ||  |\n  ++   |||++|||      ++                 ++  ||  +-------+| ++\n  ||   |||+-+||      ||                 ||  ||  |     +--+ ||\n  ++   ||+---+|      ++                 ++  ||  |     +---+++\n  |    |+-++--+                             ||  +--------+| |\n  |+---+--+|                                |+-----------+| |\n  |+-------+                                +----+ +------+ |\n  |                                              | |        |\n  |        +-+                +-+                | |        |\n  |        +-+                +-+                +-+        |\n  |                     +-----+ |    ++    +-----+ |    ++  |\n  |                     +-++----+    ++    +-++----+    ++  |\n  |                       ++                 ++             |\n  |                       ||                 ||             |\n  ++                 ++   |+-------------+   |+-------------+\n  ||                 ||   |              |   |              |\n  ++                 ++   +---+ +--------+   +---+ +--------+\n  |                           | |                | |        |\n  |                           | |                | |        |\n  |                           | |                | |        |\n  |                           | |                | |        |\n  |        +-+                | |                | |        |\n  |        | |                +-+                | |        |\n  |        | |                                   | |        |\n  |        | |                                   | +-----+  |\n  |      +-+ +-+                                 |    +-+|  |\n  |      |     |             +----+              +-+  | ||  |\n  +------+     +------+      |+--+|  ++-------+    +--+ |+--+\n  |                   |      ||++||  ||       +--+      |   |\n  +-------------------+      ||++||  ++------+   +---+  +---+\n  |                          |+--+|          |       |      |\n  |                          +----+          +---+ +-+      |\n  |                                              | |        |\n  |                                              | |        |\n  |        +-+                +-+                | |        |\n  |        +-+                | |                +-+        |\n  |                           | |          +-----+ |    ++  |\n  |                      +----+ |          +-++----+    ++  |\n  |                      |+-----+    ++      ++             |\n  |                      ||          ||      ||             |\n  +-------------------+  ||  +-------+| ++   |+-------------+\n  |                   |  ||  |     +--+ ||   |              |\n  +------+     +------+  ||  |     +---+++   +---+ +--------+\n  |      |     |         ||  +--------+|         | |        |\n  |      +-+ +-+         |+-----------+|         | |        |\n  |        | |           +----+ +------+         | |        |\n  |        | |                | |                | |        |\n  |        | |                | |                | |        |\n  |        | |                +-+                +-+        |\n  |        | |                               +------+       |\n  |        | +-----+                         |+----+|       |\n  |        |    +-+|                         ||+--+||       |\n  |        +-+  | ||         +----+          |||++|||       |\n  +-----+    +--+ |+--+      |+--+|  ++--+   |||++|||      ++\n  |     +--+      |   |      ||++||  ||  |   |||+-+||      ||\n  +----+   +---+  +---+      ||++||  ++--+   ||+---+|      ++\n  |    |       |             |+--+|          |+-++--+       |\n  |    +---+ +-+             +----+      +---+--+|          |\n  |        | |                           +-------+          |\n  |        | |                                              |\n  |        | |                +-+                +-+        |\n  +--------+-+----------------+-+----------------+-+--------+"
]
puts Benchmark.measure {
  # 10.times do
    for s in shapes
      # puts s
      # break_evil_pieces(s)
      print_solution ( break_evil_pieces(s) )
    # end
  end
}