def decompose(s)

        def sum_of_squares(a)
                a.map { |n| n**2 }.sum
        end

        tries = [s-1]

        until tries.size == 1 && tries[0] <= 1
                return tries if sum_of_squares(tries) == s**2
        
                if tries[-1] == 1
                        tries.pop
                        tries[-1] -= 1
                else
                        tries.push( [tries[-1] -1, Math.sqrt( s**2 - sum_of_squares(tries) ).floor].min )
                end
        end
        return nil
end

(1..20).each{ |i| puts decompose(i).to_s }
