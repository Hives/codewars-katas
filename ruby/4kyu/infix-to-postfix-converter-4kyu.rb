class String
  def is_a_number
    ("0".."9").include? self
  end
  def is_an_operator
    ["-", "+", "/", "*", "^"].include? self
  end
end

def to_postfix(infix)
  # https://en.wikipedia.org/wiki/Shunting-yard_algorithm
  infix = infix.split("").reverse
  output = ""
  stack = []
  precedence = {
    "^" => 4,
    "*" => 3,
    "/" => 3,
    "-" => 2,
    "+" => 2
  }
  associativity = {
    "^" => "right",
    "*" => "left",
    "/" => "left",
    "-" => "left",
    "+" => "left"
  }

  while infix.length > 0 do
    t = infix.pop
    if t.is_a_number
      output += t
    elsif t.is_an_operator
      while ((stack[-1] && stack[-1].is_an_operator && (precedence[stack[-1]] > precedence[t])) ||
            (stack[-1] && stack[-1].is_an_operator && precedence[stack[-1]] == precedence[t] && associativity[stack[-1]] == "left")) &&
            (stack[-1] != "(")
        output += stack.pop
      end
      stack += [t]
    elsif t == "("
      stack += [t]
    elsif t == ")"
      while stack[-1] != "("
        output += stack.pop
      end
      stack.pop # get rid of the left bracket which ended the while loop
    end
  end

  while stack.size > 0
    output += stack.pop
  end

  output

end

puts to_postfix("5+(6-2)*9+3^(7-1)")
