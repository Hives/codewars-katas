def openOrSenior(data)
        data.map { |d| d[0] < 55 ? "Open" : d[1] > 7 ? "Senior" : "Open" }
end

puts openOrSenior([[18, 20],[45, 2],[61, 12],[37, 6],[21, 21],[78, 9]])
