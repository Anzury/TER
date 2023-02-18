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
        #end
    end
    return objective_value, gap, l_max, l_min, time
end

# Writes the result data into an Excel file
function writeExcel(xfile::String, datafile::String)
    filename = split(datafile, "_")
    XLSX.openxlsx(xfile, mode="w") do xf
        sheet = xf[1]
        XLSX.rename!(sheet, filename[1] * filename[2])
        sheet["A1"] = "Instance"
        sheet["B1"] = "Objective value"
        sheet["C1"] = "Gap"
        sheet["D1"] = "L_max"
        sheet["E1"] = "L_min"
        sheet["F1"] = "Time"
        for i in 2:31
            objective_value, gap, l_max, l_min, time = readfile(datafile)
            sheet["A"*string(i)] = string(i - 1)
            sheet["B"*string(i)] = objective_value
            sheet["C"*string(i)] = gap
            sheet["D"*string(i)] = l_max
            sheet["E"*string(i)] = l_min
            sheet["F"*string(i)] = time
        end
    end
end

# test purposes
readfile("./results/100_60_[1,4]_3300_1.txt")

# test purposes
writeExcel("MILP_results.xlsx")
