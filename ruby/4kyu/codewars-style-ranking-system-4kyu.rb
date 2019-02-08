class User
        def initialize
                @progress = 0
                @levels = (-8..8).to_a - [0]
        end
        def progress
                self.rank < 8 ? @progress % 100 : 0
        end
        def rank
                @levels[self.level]
        end
        def level
                [(@progress/100).to_i, 15].min
        end
        def inc_progress(n)
                d = @levels.index(n) - (@progress/100).to_i
                old_progress = @progress
                @progress += 1 if d == -1
                @progress += 3 if d == 0
                @progress += 10 * d * d if d > 0
                puts "d = #{d}, progress += #{@progress - old_progress}"
                puts "Progress: #{self.progress}, rank: #{self.rank}"
                return true
        end
                
end

