for i in 2:5
    sheet["A"*string(i)] = string(i - 1)
    sheet["B"*string(i)] = readfile("./results/12_20_[1,6]_1700_" * string(i - 1) * ".txt")[1]
    sheet["C"*string(i)] = readfile("./results/12_20_[1,6]_1700_" * string(i - 1) * ".txt")[2]
    sheet["D"*string(i)] = readfile("./results/12_20_[1,6]_1700_" * string(i - 1) * ".txt")[3]
    sheet["E"*string(i)] = readfile("./results/12_20_[1,6]_1700_" * string(i - 1) * ".txt")[4]
    sheet["F"*string(i)] = readfile("./results/12_20_[1,6]_1700_" * string(i - 1) * ".txt")[5]
end