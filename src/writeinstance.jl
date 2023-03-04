using XLSX

"""
    Write results from MILP instances to an XL file name.
"""

function readfile(file)
    objective_value::Float64, gap::Float64, l_max::Float64, l_min::Float64, time::Float64 = 0.0, 0.0, 0.0, 0.0, 0.0
    open(file) do f
        lines = readlines(f)
        #if lines[4] != "  Termination status : TIME_LIMIT"
        tmp_line = split(lines[13], " ")
        objective_value = parse(Float64, tmp_line[end])
        tmp_line = split(lines[15], " ")
        gap = parse(Float64, tmp_line[end])
        tmp_line = split(lines[18], " ")
        l_max = parse(Float64, tmp_line[end])
        tmp_line = split(lines[19], " ")
        l_min = parse(Float64, tmp_line[end])
        tmp_line = split(lines[end-4], " ")
        time = parse(Float64, tmp_line[end])
        if time > 600
            time = 600
        end
        #end
    end
    return objective_value, gap, l_max, l_min, time
end

# Writes the result data into an Excel file
function writeExcel(xfile::String, datafile::String)
    file_name = split(datafile, "_")
    data_type = file_name[1][11:end]*"_"*file_name[2]
    number = parse(Int64, file_name[end][1:end-4])
    if !isfile(xfile)
        XLSX.openxlsx(xfile, mode="w") do xf
            sheet = xf[1]
            XLSX.rename!(sheet, data_type)
            sheet["A1"] = "Instance"
            sheet["B1"] = "Objective value"
            sheet["C1"] = "Gap"
            sheet["D1"] = "L_max"
            sheet["E1"] = "L_min"
            sheet["F1"] = "Time"
            objective_value, gap, l_max, l_min, time = readfile(datafile)
            sheet["A"*string(number+1)] = string(number)
            sheet["B"*string(number+1)] = objective_value
            sheet["C"*string(number+1)] = gap
            sheet["D"*string(number+1)] = l_max
            sheet["E"*string(number+1)] = l_min
            sheet["F"*string(number+1)] = time
        end
    else
        XLSX.openxlsx(xfile, mode="rw") do xf
            if data_type ∉ XLSX.sheetnames(xf)
                sheet = XLSX.addsheet!(xf, data_type)
                sheet["A1"] = "Instance"
                sheet["B1"] = "Objective value"
                sheet["C1"] = "Gap"
                sheet["D1"] = "L_max"
                sheet["E1"] = "L_min"
                sheet["F1"] = "Time"
                objective_value, gap, l_max, l_min, time = readfile(datafile)
                sheet["A"*string(number+1)] = string(number)
                sheet["B"*string(number+1)] = objective_value
                sheet["C"*string(number+1)] = gap
                sheet["D"*string(number+1)] = l_max
                sheet["E"*string(number+1)] = l_min
                sheet["F"*string(number+1)] = time
            else
                sheet = xf[data_type]
                objective_value, gap, l_max, l_min, time = readfile(datafile)
                sheet["A"*string(number+1)] = string(number)
                sheet["B"*string(number+1)] = objective_value
                sheet["C"*string(number+1)] = gap
                sheet["D"*string(number+1)] = l_max
                sheet["E"*string(number+1)] = l_min
                sheet["F"*string(number+1)] = time
            end
        end
    end
end

# test purposes
# readfile("../results/100_60_[1,4]_3300_1.txt")

# test purposes
# writeExcel("MILP_results.xlsx","./results/12_20_[1,6]_1700_1.txt")
# println("Passage au deuxième fichier")
# writeExcel("MILP_results.xlsx","./results/12_20_[1,6]_1700_2.txt")
# println("Passage au troisième fichier")
# writeExcel("MILP_results.xlsx","./results/100_60_[1,4]_3300_1.txt")

target = "./results/"
fnames = getfname(target)

for names in fnames
    writeExcel("MILP_results.xlsx", "./results/"*names)
end
