def mix(s1, s2)
  alpha = ("a".."z").to_a
  c = []
  alpha.each do |l|
    s1c = s1.count(l)
    s2c = s2.count(l)
    if s1c > 1 || s2c > 1
      which = s1c > s2c ? "1" : s2c > s1c ? "2" : "="
      c += ["#{which}:#{l * [s1c, s2c].max}"]
    end
  end
  c.sort! { |a,b| a <=> b }
  c.sort! { |a,b| b.size <=> a.size }
  return c.join("/")
end

p mix("Are they here", "yes, they are here")
# "2:eeeee/2:yy/=:hh/=:rr"

p mix("looping is fun but dangerous", "less dangerous than coding")
# "1:ooo/1:uuu/2:sss/=:nnn/1:ii/2:aa/2:dd/2:ee/=:gg")

# " In many languages", " there's a pair of functions"), "1:aaa/1:nnn/1:gg/2:ee/2:ff/2:ii/2:oo/2:rr/2:ss/2:tt")
# "Lords of the Fallen", "gamekult"), "1:ee/1:ll/1:oo")
# "codewars", "codewars"), "")
# "A generation must confront the looming ", "codewarrs"), "1:nnnnn/1:ooooo/1:tttt/1:eee/1:gg/1:ii/1:mm/=:rr")
