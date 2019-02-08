def train_crash(track, a_train, a_start, b_train, b_start, limit)
  puts track
  # puts a_train
  # puts a_start
  # puts b_train
  # puts b_start
  # puts limit

  @track = track.split("\n").map!{ |row| row.rstrip.split("") }
  
  def exists(j, i)
    return true if ( j >= 0 &&
                     j < @track.size &&
                     i >= 0 &&
                     i < @track[j].size &&
                     @track[j][i] != " " )
    return false
  end
  
  def is_it_a_crossroads(j, i)
    return false if !( j >= 1 &&
                       j < @track.size - 1 &&
                       i >= 1 &&
                       i < @track[j].size - 1 )
    return true if @track[j+1][i] != " " &&
                   @track[j-1][i] != " " &&
                   @track[j][i+1] != " " &&
                   @track[j][i-1] != " "
    return true if @track[j+1][i+1] != " " &&
                   @track[j+1][i-1] != " " &&
                   @track[j-1][i-1] != " " &&
                   @track[j-1][i+1] != " "
    return false
  end

  def crash_test
    positions = {}
    [:a, :b].each do |a_or_b|
      positions[a_or_b] = (0..@trains[a_or_b][:len]-1).map do |carriage|
        pos = (@trains[a_or_b][:pos] + (@trains[a_or_b][:dir] * carriage)) % @tline.size
        if @tline[pos].key?(:crossroads)
          crossroads_id = @tline[pos][:crossroads]
          alt_positions = @tline.select { |p| p[:crossroads] == crossroads_id }.map { |c| c[:pos] }
          alt_positions
        else
          pos
        end
      end.flatten
    end
    all_positions = positions[:a] + positions[:b]
    all_positions != all_positions.uniq
  end

  def draw(t)
    track_and_train = Marshal.load(Marshal.dump(@track))
    [:a, :b].each do |a_or_b|
      (0..@trains[a_or_b][:len]-1).map do |carriage|
        pos = (@trains[a_or_b][:pos] + (@trains[a_or_b][:dir] * carriage)) % @tline.size
        letter = @trains[a_or_b][:letter]
        track_and_train[@tline[pos][:j]][@tline[pos][:i]] = carriage == 0 ? letter.upcase : letter.to_s
      end
    end
    output = track_and_train.map { |row| row.join("") }.join("\n")
    output += "\nt = #{t}"
    output += "\na: #{@trains[:a][:pos]} -> #{@tline[@trains[:a][:pos]][:piece]}"
    output += "\nb: #{@trains[:b][:pos]} -> #{@tline[@trains[:b][:pos]][:piece]}"
    system "clear"
    puts output
  end

  @crossroad_details = []
  @track.each_with_index do |row, j|
    row.each_with_index do |c, i|
      if c == "+" || c == "X"
        @crossroad_details += [{piece: @track[j][i], j: j, i: i}]
      elsif c == "S"
        if is_it_a_crossroads(j, i)
          @crossroad_details += [{piece: @track[j][i], j: j, i: i}]
        end
      end
    end
  end

  i = 0; j = 0
  i += 1 until @track[j][i] != " "
  @tline = [{piece: @track[j][i], j: j, i: i, pos: 0}]
  dir = {y: 0, x: 1}
  loop do
    
    # puts "#{j}, #{i}"
    case @tline[-1][:piece]
      
    when "/"
      if dir[:x] > 0 || dir[:y] < 0
        if exists(j-1, i) && @track[j-1][i] == "|"
          # up
          j -= 1
          dir = {y: -1, x: 0}
        elsif exists(j-1, i+1) && ("/XS".include? @track[j-1][i+1])
          # up and right
          j -= 1; i += 1
          dir = {y: -1, x: 1}
        elsif exists(j, i+1) && @track[j][i+1] == "-"
          # right
          i += 1
          dir = {y: 0, x: 1}
        end
      else
        if exists(j+1, i) && @track[j+1][i] == "|"
          # down
          j += 1
          dir = {y: 1, x: 0}
        elsif exists(j+1, i-1) && ("/XS".include? @track[j+1][i-1])
          # down and left
          j += 1; i -= 1
          dir = {y: 1, x: -1}
        elsif exists(j, i-1) && @track[j][i-1] == "-"
          # left
          i -= 1
          dir = {y: 0, x: -1}
        end
      end
      
    when "\\"
      if dir[:x] > 0 || dir[:y] > 0
        if exists(j, i+1) && @track[j][i+1] == "-"
          # right
          i += 1
          dir = {y: 0, x: 1}
        elsif exists(j+1, i+1) && ("\\XS".include? @track[j+1][i+1])
          # down and right
          j += 1; i += 1
          dir = {y: 1, x: 1}
        elsif exists(j+1, i) && @track[j+1][i] == "|"
          # down
          j += 1
          dir = {y: 1, x: 0}
        end
      else
        if exists(j, i-1) && @track[j][i-1] == "-"
          # left
          i -= 1
          dir = {y: 0, x: -1}
        elsif exists(j-1, i-1) && ("\\XS".include? @track[j-1][i-1])
          # left and up
          j -= 1; i -= 1
          dir = {y: -1, x: -1}
        elsif exists(j-1, i) && @track[j-1][i] == "|"
          # up
          j -= 1
          dir = {y: -1, x: 0}
        end
      end

    when "-", "|", "+", "X", "S"
      i += dir[:x]; j += dir[:y]
    end

    # end the loop when we're back to the start:
    break if i == @tline[0][:i] && j == @tline[0][:j]

    @tline += [{piece: @track[j][i], j: j, i: i, pos: @tline.size}]
    if is_it_a_crossroads(j, i)
      @crossroad_details.each_with_index do |crossroads, index|
        if crossroads[:i] == i && crossroads[:j] == j
          @tline[-1][:crossroads] = index
        end
      end
    end

  end

  @trains = {
    a: {
      pos: a_start,
      dir: a_train[0].upcase == a_train[0] ? 1 : -1,
      len: a_train.size,
      pause: 0,
      express: a_train[0].downcase == "x",
      letter: a_train[0].downcase,
    },
    b: {
      pos: b_start,
      dir: b_train[0].upcase == b_train[0] ? 1 : -1,
      len: b_train.size,
      pause: 0,
      express: b_train[0].downcase == "x",
      letter: b_train[0].downcase,
    }
  }

  (0..limit).each do |t|
    draw(t)
    return t if crash_test
    [:a, :b].each do |a_or_b|
      if @trains[a_or_b][:pause] == 0
        @trains[a_or_b][:pos] -= @trains[a_or_b][:dir]
        @trains[a_or_b][:pos] = @trains[a_or_b][:pos] % @tline.size
        if @tline[@trains[a_or_b][:pos]][:piece] == "S" &&
           !@trains[a_or_b][:express]
          @trains[a_or_b][:pause] = @trains[a_or_b][:len] - 1
        end
      else
        # puts "train #{a_or_b} is in the station"
        @trains[a_or_b][:pause] -= 1
      end
    end
    # blah = gets
    sleep(0.05)
  end

  return -1

end

TRACK_EX_ = """\
                                /------------\\
/-------------\\                /             |
|             |               /              S
|             |              /               |
|        /----+--------------+------\\        |   
\\       /     |              |      |        |     
 \\      |     \\              |      |        |                    
 |      |      \\-------------+------+--------+---\\
 |      |                    |      |        |   |
 \\------+--------------------+------/        /   |
        |                    |              /    | 
        \\------S-------------+-------------/     |
                             |                   |
/-------------\\              |                   |
|             |              |             /-----+----\\
|             |              |             |     |     \\
\\-------------+--------------+-----S-------+-----/      \\
              |              |             |             \\
              |              |             |             |
              |              \\-------------+-------------/
              |                            |               
              \\----------------------------/ 
"""
p train_crash(TRACK_EX_, "Aaaa", 147, "Bbbbbbbbbbb", 288, 1000) #516

# TRACK_EX_ = """\
# /-----------------\\
# |                 |
# |                 |
# |                 |
# |                 |
# \\---------S-------/
# """
# p train_crash(TRACK_EX_, "xX", 10, "xxxxxX", 30, 200) #-1

# TRACK_EX_ = """\
# /-------\\ 
# |       | 
# |       | 
# \\-------+-------------------------------------------------------------------\\ 
#         |                                                                   |
#         |                                                                   |
#         \\-------------------------------------------------------------------/
# """
# p train_crash(TRACK_EX_, "aA", 10, "oooooooooooooooooooooooooO", 70, 200) # 105

# TRACK_EX_ = """\
# /-----\\   /-----\\   /-----\\   /-----\\ 
# |      \\ /       \\ /       \\ /      | 
# |       X         X         X       | 
# |      / \\       / \\       / \\      | 
# \\-----/   \\-----/   \\-----/   \\-----/
# """
# p train_crash(TRACK_EX_, "Eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", 27, "Xxxx", 0, 100)

# TRACK_EX_ = """\
#     /---------------------\\               /-\\ /-\\  
#    //---------------------\\\\              | | | |  
#   //  /-------------------\\\\\\             | / | /  
#   ||  |/------------------\\\\\\\\            |/  |/   
#   ||  ||                   \\\\\\\\           ||  ||   
#   \\\\  ||                   | \\\\\\          ||  ||   
#    \\\\-//                   | || \\---------/\\--/|   
# /-\\ \\-/                    \\-/|                |   
# |  \\--------------------------/                |   
# \\----------------------------------------------/   
# """
# p train_crash(TRACK_EX_, "aaaA", 15, "bbbB", 5, 1000)
