def alphabet_position(text)
    s = text.split("")
    output = ""
    s.each { |l|
      l.downcase!
      if "abcdefghijklmnopqrstuvwxyz".include? l
        value = l.ord - 96
        output << "#{value} "
      end
    }
    output = output[0...-1] if output.length > 0
    return output
end

puts alphabet_position("the opposite of plethora is dearth")
