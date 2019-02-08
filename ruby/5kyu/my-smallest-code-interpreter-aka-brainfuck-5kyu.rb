def brain_luck(code, input)
        @code = code
        @code_pointer = 0
        @mem = [0]
        @mem_pointer = 0
        @input = input.reverse.chars
        @output = ""
        @bracket_count = 0
        
        def jump_forwards_if_mem_is_zero
                if @mem[@mem_pointer] == 0
                        bracket_count = 1
                        while bracket_count > 0
                                @code_pointer += 1
                                bracket_count += 1 if @code[@code_pointer] == "["
                                bracket_count -= 1 if @code[@code_pointer] == "]"
                        end
                end
        end
        
        def jump_backwards_if_mem_is_nonzero
                if @mem[@mem_pointer] != 0
                        bracket_count = 1
                        while bracket_count > 0
                                @code_pointer -= 1
                                bracket_count += 1 if @code[@code_pointer] == "]"
                                bracket_count -= 1 if @code[@code_pointer] == "["
                        end
                end
        end
        
        def execute_one_byte_of_code
                puts "--"
                puts "code: #{@code[@code_pointer]}"
                puts "mem_pointer: #{@mem_pointer}"
                puts "mem: #{@mem}"
                case @code[@code_pointer]
                when ">" then @mem_pointer += 1; @mem[@mem_pointer] = 0 if !@mem[@mem_pointer]
                when "<" then @mem_pointer -= 1
                when "+" then @mem[@mem_pointer] = ( @mem[@mem_pointer] + 1 ) % 256
                when "-" then @mem[@mem_pointer] = ( @mem[@mem_pointer] - 1 ) % 256
                when "." then @output << @mem[@mem_pointer].chr
                when "," then @mem[@mem_pointer] = @input.pop.ord
                when "["
                        jump_forwards_if_mem_is_zero
                when "]"
                        jump_backwards_if_mem_is_nonzero
                end
        end

        while @code_pointer < @code.size
                execute_one_byte_of_code
                @code_pointer += 1
        end

        @output
end

puts brain_luck(',+[-.,+]', 'Codewars' + 255.chr)
puts "------------------"
puts brain_luck(',>,<[>[->+>+<<]>>[-<<+>>]<<<-]>>.', 8.chr + 9.chr)
