def the_lift(queues, capacity)
        floor = 0
        top_floor = queues.size - 1
        stops = [0]
        lift = []
        direction = -1

        until queues.all? { |a| a == [] } do

                while floor.between?(0, top_floor)

                        stop = false
                        
                        # disembark
                        stop = true if lift.delete(floor)

                        # embark
                        queues[floor].delete_if do |f|
                                if (direction == 1 && f.between?(floor, top_floor)) ||
                                   (direction == -1 && f.between?(0, floor))
                                        stop = true
                                        if lift.size < capacity
                                                lift += [f]
                                                true
                                        else
                                                false
                                        end
                                else
                                        false
                                end
                        end

                        stops += [floor] if (stop && stops[-1] != floor)

                        floor += direction
                end

                floor = [floor, top_floor].min
                floor = [floor, 0].max

                direction *= -1

        end

        stops += [0] if stops[-1] != 0
        stops
end

tests = [[ [ [],   [],    [5,5,5], [],   [],    [],    [] ],     [0, 2, 5, 0]          ],
         [ [ [],   [],    [1,1],   [],   [],    [],    [] ],     [0, 2, 1, 0]          ],
         [ [ [],   [3,],  [4,],    [],   [5,],  [],    [] ],     [0, 1, 2, 3, 4, 5, 0] ],
         [ [ [],   [0,],  [],      [],   [2,],  [3,],  [] ],     [0, 5, 4, 3, 2, 1, 0] ],
         [ [ [1],  [2],   [3],     [],   [],    [3],   [2]],     [0,1,2,3,6,5,3,2,0]   ]]

for queues, answer in tests do
        puts "THE ANSWER: #{the_lift(queues, 5).to_s}"
end
