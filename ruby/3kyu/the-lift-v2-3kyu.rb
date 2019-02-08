def the_lift(queues, capacity)
  stops = [0]
  passengers = []

  floors_and_queues = queues.each_with_index.map { |queue, floor| [queue, floor] }

  until floors_and_queues.all? { |queue, floor| queue == [] } do

    later_floors = floors_and_queues.map { |queue, floor| floor }

    floors_and_queues.map do |queue, floor|
      later_floors = later_floors.drop(1)

      stop = false

      # disembark
      stop = true if passengers.delete(floor)

      # embark
      queue.delete_if do |destination|
        if later_floors.include? destination
          stop = true
          if passengers.size < capacity
            passengers += [destination]
            true
          else
            false
          end
        else
          false
        end
      end

      stops += [floor] if (stop && stops[-1] != floor)
      [floor, queue]
    end

    floors_and_queues.reverse!
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
