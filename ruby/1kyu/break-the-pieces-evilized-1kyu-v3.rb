def break_evil_pieces(shape)
  return [] if !shape.include? "+"
  shape = shape.split(/\n+/)
  blocks = []
  block_ids = []
  solution = []

  def trans(shape)
    shape.map! do |row|
      row.map do |c|
        if c[:c] == "-"
          new_c = "|"
        elsif c[:c] == "|"
          new_c = "-"
        else
          new_c = c[:c]
        end
        {og: c[:og], c: new_c}
      end
    end
    return shape.transpose
  end

  def expand_vert(shape)
    shape_expanded = []
    (0..shape.size-1).to_a.each do |j|
      if j > 0
        expansion_line = []
        we_need_expansion_line = false

        (0..shape[j].size-1).to_a.each do |i|

          if ("+|".include? shape[j][i][:c]) &&
             ("+|".include? shape[j-1][i][:c])
            expansion_line += [{og: false, c: "|"}]
          else
            expansion_line += [{og: false, c: " "}]
          end

          if ("+-".include? shape[j][i][:c]) &&
             ("+-".include? shape[j-1][i][:c])
            we_need_expansion_line = true
          end

        end
        shape_expanded += [expansion_line] if we_need_expansion_line
      end
      shape_expanded += [shape[j]]
    end
    return shape_expanded
  end

  def printy(shape)
    shape.each do |row|
      p row.map{ |c| c[:c] }.join("")
    end
  end
  
  # pad lines to length of longest line so we can transpose later, and
  # convert rows from strings to arrays
  length = shape.map{ |line| line.size }.max
  shape.map!{ |line| line.ljust(length, " ").chars }
  
  # trim blank rows and columns from edges
  [:r,:c].each do |r_or_c|
    shape = shape.transpose if r_or_c == :c
    shape.pop while shape[-1].uniq == [" "]
    shape.shift while shape[0].uniq == [" "]
    shape = shape.transpose if r_or_c == :c
  end

  # replace each character with a hash containing the character and the og status
  shape = shape.map { |row| row.map { |c| {og: true, c: c} } }

  [:r,:c].each do |r_or_c|
    shape = trans(shape) if r_or_c == :c
    shape = expand_vert(shape)
    shape = trans(shape) if r_or_c == :c
  end

  shape.each_with_index do |line, j|
    blocks += [[]]
    line.each_with_index do |c, i|

      # if c is " " we're inside a block
      if c[:c] == " "

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


  if blocks.size > 0
    # ignore blocks which touch the outside
    outside = blocks[0] + blocks[-1] + blocks.transpose[0] + blocks.transpose[-1]
    outside = outside.uniq - [0]
    block_ids.delete_if{ |ids| !(ids & outside).empty? }

    # convert each block into its outline
    block_ids.each do |ids|

      outline = []

      # shape2 = Marshal.load(Marshal.dump(shape))
      # copy outline from original shape
      shape.each_with_index do |line, j|
        outline += [[]]
        line.each_with_index do |c, i|
          if c[:og]
            if ids.include? blocks[j][i]
              # c[:c] = " "
              outline[-1] += [{c: " ", og: c[:og]}]
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
                # c[:c] = " "
                # outline[-1] += [c]
                outline[-1] += [{c: " ", og: c[:og]}]
              else
                outline[-1] += [{c: c[:c], og: c[:og]}]
              end
            end
          end
        end
        outline.pop if outline[-1] == []
      end

      # trim blank lines and columns
      [:r, :c].each do |r_or_c|
        outline = outline.transpose if r_or_c == :c
        outline.delete_if { |line| line.map{ |c| c[:c] }.uniq == [" "] }
        outline = outline.transpose if r_or_c == :c
      end

      # remove the extra lines we added

      # outline.each{ |r| p r }
      # exit
      outline = outline.transpose.delete_if{ |line| line == [] || line.map{ |c| c[:c] }.uniq == [" "] }.transpose
      outline = outline.transpose.delete_if{ |line| line.uniq == [" "] }.transpose

      # puts "outline:"
      # puts outline.map { |r| r.map { |c| c[:c] }.join }
      # exit
      
      # p outline
      # exit

      printy(outline)
      exit
      
      # remove unnecessary crosses
      outline.map!.each_with_index do |line, j|
        line.map!.each_with_index do |c, i|
          if c[:c] == "+"
            cross = []

            # get vertical and horizontal neighbours
            [[0,-1],[1,0],[0,1],[-1,0]].each do |x, y|
              if ((0..outline.size-1).include? (j+y)) &&
                 ((0..outline[j+y].size-1).include? (i+x))
                cross += [outline[j+y][i+x][:c]]
              else
                cross += [" "]
              end
            end

            # straight vertical
            if (["|", "+"].include? cross [0]) &&
               ([" ", "|"].include? cross [1]) &&
               (["|", "+"].include? cross [2]) &&
               ([" ", "|"].include? cross [3])
              c[:c] = "|"

            # straight horizontal
            elsif ([" ", "-"].include? cross [0]) &&
                  (["-", "+"].include? cross [1]) &&
                  ([" ", "-"].include? cross [2]) &&
                  (["-", "+"].include? cross [3])
              c[:c] = "-"
            else
              c[:c] = "+"
            end
          end
          c
        end
      end

      # outline.each { |r| p r.map{ |c| c[:og] }.uniq }
      # exit


      # remove the rows and columns of padding we added
      [:r, :c].each do |r_or_c|
        outline = outline.transpose if r_or_c == :c
        outline.delete_if { |line| line.map{ |c| c[:og] }.uniq == [false] }
        outline = outline.transpose if r_or_c == :c
      end


      # remove even rows and columns (actually odd though since starts from 0)
      # outline.delete_if.each_with_index { |row, j| j % 2 == 1 }
      # outline.map! do |row|
      #   row.delete_if.each_with_index { |c, i| i % 2 == 1 }
      # end


      # tidy up outline
      outline.map! { |r| r.map { |c| c[:c] }.join.rstrip }
      # outline.map! { |line| line.join.rstrip }
      # solution += [outline.map{ |r| r.map { |c| c[:c] }.join }.join("\n")]
      solution += [outline.join("\n")]

    end
  
    solution

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
  "                       \n   +-----------------+ \n   |+--------++-----+| \n   ||        ++     || \n   |+--------+|     || \n +++----------+     || \n |++----------------+| \n |||+----------------+ \n ||||                  \n |||+------+           \n ||+-------+           \n |+--------+           \n +---------+           \n                       \n +-----------+         \n |+++------++|         \n ||++      ++|         \n ||        |||         \n |+--------+||         \n +----------+|         \n +-----------+         \n                       "
  # "\n"
]
for s in shapes
  puts s
  # puts Benchmark.measure { break_evil_pieces(s) }
  print_solution ( break_evil_pieces(s) )
end
