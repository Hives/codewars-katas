def likes(names)
        return "no one likes this" if names.length == 0
        case names.length
        when 1
                return "#{names[0]} likes this"
        when 2
                return "#{names[0]} and #{names[1]} like this"
        when 3
                return "#{names[0]}, #{names[1]} and #{names[2]} like this"
        else
                return "#{names[0]}, #{names[1]} and #{names.length - 2} others like this"
        end
end

puts likes []
puts likes ["Peter"]
puts likes ["Jacob", "Alex"]
puts likes ["Max", "John", "Mark"]
puts likes ["Alex", "Jacob", "Mark", "Max"]
