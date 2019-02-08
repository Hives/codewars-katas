def last_digit(n1, n2)
        # see https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
        base = n1; exponent = n2; e_dash = 0; modulus = 10
        result = 1
        base = base % modulus
        while exponent > 0
                if exponent % 2 == 1
                        result = (result * base) % modulus
                end
                exponent /= 2
                base = (base * base) % modulus
        end
        result
end

puts last_digit(4, 1)                # returns 4
puts last_digit(4, 2)                # returns 6
puts last_digit(9, 7)                # returns 9
puts last_digit(10, 10 ** 10)        # returns 0
puts last_digit(2 ** 200, 2 ** 300)  # returns 6
