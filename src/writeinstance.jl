using XLSX

include("loadinstance.jl")
include("datastructMILP.jl")
# include("main.jl")

"""
    Write results from MILP instances to an XL file name.
"""

function readfile(file)
    objective_value::Float64, gap::Float64, l_max::Float64, l_min::Float64, time::Float64 = 0.0, 0.0, 0.0, 0.0, 0.0
    open(file) do f
        lines = readlines(f)
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
    end
    return objective_value, gap, l_max, l_min, time
end

function readfile_results(file)
    mail_batch::Int64, round::Int64, output::Int64 = 0, 0, 0
    # compute X
    file_name = basename(file)
    println(file_name)
    excel_name = file_name[1:end-4] * ".xlsx"
    type_tmp = split(file_name, "_")
    println(type_tmp)
    type = type_tmp[1] * "_" * type_tmp[2]
    println(type)
    X = loadinstanceMILP("../data/$type/$excel_name").X
    open(file) do f
        lines = readlines(f)
        for i in 20:length(lines)-7
            words = split(lines[i], (',', ':', '[', ']', ' '))
            # println(words)
            mail_batch = parse(Int64, words[6])
            round = parse(Int64, words[7])
            output = parse(Int64, words[8])
            x = Int(parse(Float64, words[end]))
            # println(mail_batch)
            # println(round)
            # println(output)
            # println(x)
            X[mail_batch][round][output] = x
            # println(X)
        end
        # println(words)
    end
    println("Fin de la lecture")
    println(typeof(X))
    println(size(X)[1])
    # Remake the matrix with the results in X
    final_x = []
    for i in 1:size(X)[1]
        println("Je lis les i : ", i)
        for j in 1:size(X)[2]
            println("Je lis les j : ", j)
            for k in 1:size(X)[3]
                println("Je lis les k : ", k)
                println("final_x avant modif : ", final_x)
                final_x[i,j] += X[i][j][k]
                println("final_x après modif : ", final_x)
            end
        end
    end
    println(X)
end

# Writes the result data into an Excel file
function writeExcel(xfile::String, datafile::String)
    file_name = split(datafile, "_")
    println(file_name)
    data_type = file_name[1][11:end] * "_" * file_name[2]
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
            sheet["A"*string(number + 1)] = string(number)
            sheet["B"*string(number + 1)] = objective_value
            sheet["C"*string(number + 1)] = gap
            sheet["D"*string(number + 1)] = l_max
            sheet["E"*string(number + 1)] = l_min
            sheet["F"*string(number + 1)] = time
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
                sheet["A"*string(number + 1)] = string(number)
                sheet["B"*string(number + 1)] = objective_value
                sheet["C"*string(number + 1)] = gap
                sheet["D"*string(number + 1)] = l_max
                sheet["E"*string(number + 1)] = l_min
                sheet["F"*string(number + 1)] = time
            else
                sheet = xf[data_type]
                objective_value, gap, l_max, l_min, time = readfile(datafile)
                sheet["A"*string(number + 1)] = string(number)
                sheet["B"*string(number + 1)] = objective_value
                sheet["C"*string(number + 1)] = gap
                sheet["D"*string(number + 1)] = l_max
                sheet["E"*string(number + 1)] = l_min
                sheet["F"*string(number + 1)] = time
            end
        end
    end
end

# Reads the results from the Opti_move heuristic
function read_heuristic(xfile::String, datafile::String)
    file_name = split(datafile, ('_', '.', '/'))
    data_type = file_name[5] * "_" * file_name[6]
    number = parse(Int64, file_name[end-1])
    if !isfile(xfile)
        XLSX.openxlsx(xfile, mode="w") do xf
            sheet = xf[1]
            XLSX.rename!(sheet, data_type)
            sheet["A1"] = "Instance"
            sheet["B1"] = "Objective value"
            sheet["C1"] = "Pourcentage"
            sheet["D1"] = "Décroissance"
            sheet["E1"] = "Nombre d'itération stagnante"
            sheet["F1"] = "Nombre d'itération améliorante 1"
            sheet["G1"] = "f1 1"
            sheet["H1"] = "f2 1"
            sheet["I1"] = "f3 1"
            sheet["J1"] = "Time 1"
            sheet["K1"] = "Nombre d'itération améliorante 2"
            sheet["L1"] = "f1 2"
            sheet["M1"] = "f2 2"
            sheet["N1"] = "f3 2"
            sheet["O1"] = "Time 2"
            sheet["P1"] = "Nombre d'itération améliorante 3"
            sheet["Q1"] = "f1 3"
            sheet["R1"] = "f2 3"
            sheet["S1"] = "f3 3"
            sheet["T1"] = "Time 3"
            sheet["U1"] = "Nombre d'itération améliorante 4"
            sheet["V1"] = "f1 4"
            sheet["W1"] = "f2 4"
            sheet["X1"] = "f3 4"
            sheet["Y1"] = "Time 4"
            sheet["Z1"] = "Nombre d'itération améliorante 5"
            sheet["AA1"] = "f1 5"
            sheet["AB1"] = "f2 5"
            sheet["AC1"] = "f3 5"
            sheet["AD1"] = "Time 5"
            open(datafile) do f
                lines = readlines(f)
                sheet["A"*string(number + 1)] = string(number)
                sheet["B"*string(number + 1)] = parse(Float64, split(lines[1], " ")[end])
                sheet["C"*string(number + 1)] = parse(Float64, split(lines[2], " ")[end])
                sheet["D"*string(number + 1)] = parse(Float64, split(lines[3], " ")[end])
                sheet["E"*string(number + 1)] = parse(Int64, split(lines[4], " ")[end])
                sheet["F"*string(number + 1)] = parse(Int64, split(lines[5], " ")[end])
                sheet["G"*string(number + 1)] = parse(Float64, split(lines[6], " ")[end])
                sheet["H"*string(number + 1)] = parse(Float64, split(lines[7], " ")[end])
                sheet["I"*string(number + 1)] = parse(Float64, split(lines[8], " ")[end])
                sheet["J"*string(number + 1)] = parse(Float64, split(lines[9], " ")[end][1:end-1])
                sheet["K"*string(number + 1)] = parse(Int64, split(lines[10], " ")[end])
                sheet["L"*string(number + 1)] = parse(Float64, split(lines[11], " ")[end])
                sheet["M"*string(number + 1)] = parse(Float64, split(lines[12], " ")[end])
                sheet["N"*string(number + 1)] = parse(Float64, split(lines[13], " ")[end])
                sheet["O"*string(number + 1)] = parse(Float64, split(lines[14], " ")[end][1:end-1])
                sheet["P"*string(number + 1)] = parse(Int64, split(lines[15], " ")[end])
                sheet["Q"*string(number + 1)] = parse(Float64, split(lines[16], " ")[end])
                sheet["R"*string(number + 1)] = parse(Float64, split(lines[17], " ")[end])
                sheet["S"*string(number + 1)] = parse(Float64, split(lines[18], " ")[end])
                sheet["T"*string(number + 1)] = parse(Float64, split(lines[19], " ")[end][1:end-1])
                sheet["U"*string(number + 1)] = parse(Int64, split(lines[20], " ")[end])
                sheet["V"*string(number + 1)] = parse(Float64, split(lines[21], " ")[end])
                sheet["W"*string(number + 1)] = parse(Float64, split(lines[22], " ")[end])
                sheet["X"*string(number + 1)] = parse(Float64, split(lines[23], " ")[end])
                sheet["Y"*string(number + 1)] = parse(Float64, split(lines[24], " ")[end][1:end-1])
                sheet["Z"*string(number + 1)] = parse(Int64, split(lines[25], " ")[end])
                sheet["AA"*string(number + 1)] = parse(Float64, split(lines[26], " ")[end])
                sheet["AB"*string(number + 1)] = parse(Float64, split(lines[27], " ")[end])
                sheet["AC"*string(number + 1)] = parse(Float64, split(lines[28], " ")[end])
                sheet["AD"*string(number + 1)] = parse(Float64, split(lines[29], " ")[end][1:end-1])
            end
        end
    else
        XLSX.openxlsx(xfile, mode="rw") do xf
            if data_type ∉ XLSX.sheetnames(xf)
                sheet = XLSX.addsheet!(xf, data_type)
                sheet["A1"] = "Instance"
                sheet["B1"] = "Objective value"
                sheet["C1"] = "Pourcentage"
                sheet["D1"] = "Décroissance"
                sheet["E1"] = "Nombre d'itération stagnante"
                sheet["F1"] = "Nombre d'itération améliorante 1"
                sheet["G1"] = "f1 1"
                sheet["H1"] = "f2 1"
                sheet["I1"] = "f3 1"
                sheet["J1"] = "Time 1"
                sheet["K1"] = "Nombre d'itération améliorante 2"
                sheet["L1"] = "f1 2"
                sheet["M1"] = "f2 2"
                sheet["N1"] = "f3 2"
                sheet["O1"] = "Time 2"
                sheet["P1"] = "Nombre d'itération améliorante 3"
                sheet["Q1"] = "f1 3"
                sheet["R1"] = "f2 3"
                sheet["S1"] = "f3 3"
                sheet["T1"] = "Time 3"
                sheet["U1"] = "Nombre d'itération améliorante 4"
                sheet["V1"] = "f1 4"
                sheet["W1"] = "f2 4"
                sheet["X1"] = "f3 4"
                sheet["Y1"] = "Time 4"
                sheet["Z1"] = "Nombre d'itération améliorante 5"
                sheet["AA1"] = "f1 5"
                sheet["AB1"] = "f2 5"
                sheet["AC1"] = "f3 5"
                sheet["AD1"] = "Time 5"
            else
                sheet = xf[data_type]
            end
            open(datafile) do f
                lines = readlines(f)
                sheet["A"*string(number + 1)] = string(number)
                sheet["B"*string(number + 1)] = parse(Float64, split(lines[1], " ")[end])
                sheet["C"*string(number + 1)] = parse(Float64, split(lines[2], " ")[end])
                sheet["D"*string(number + 1)] = parse(Float64, split(lines[3], " ")[end])
                sheet["E"*string(number + 1)] = parse(Int64, split(lines[4], " ")[end])
                sheet["F"*string(number + 1)] = parse(Int64, split(lines[5], " ")[end])
                sheet["G"*string(number + 1)] = parse(Float64, split(lines[6], " ")[end])
                sheet["H"*string(number + 1)] = parse(Float64, split(lines[7], " ")[end])
                sheet["I"*string(number + 1)] = parse(Float64, split(lines[8], " ")[end])
                sheet["J"*string(number + 1)] = parse(Float64, split(lines[9], " ")[end][1:end-1])
                sheet["K"*string(number + 1)] = parse(Int64, split(lines[10], " ")[end])
                sheet["L"*string(number + 1)] = parse(Float64, split(lines[11], " ")[end])
                sheet["M"*string(number + 1)] = parse(Float64, split(lines[12], " ")[end])
                sheet["N"*string(number + 1)] = parse(Float64, split(lines[13], " ")[end])
                sheet["O"*string(number + 1)] = parse(Float64, split(lines[14], " ")[end][1:end-1])
                sheet["P"*string(number + 1)] = parse(Int64, split(lines[15], " ")[end])
                sheet["Q"*string(number + 1)] = parse(Float64, split(lines[16], " ")[end])
                sheet["R"*string(number + 1)] = parse(Float64, split(lines[17], " ")[end])
                sheet["S"*string(number + 1)] = parse(Float64, split(lines[18], " ")[end])
                sheet["T"*string(number + 1)] = parse(Float64, split(lines[19], " ")[end][1:end-1])
                sheet["U"*string(number + 1)] = parse(Int64, split(lines[20], " ")[end])
                sheet["V"*string(number + 1)] = parse(Float64, split(lines[21], " ")[end])
                sheet["W"*string(number + 1)] = parse(Float64, split(lines[22], " ")[end])
                sheet["X"*string(number + 1)] = parse(Float64, split(lines[23], " ")[end])
                sheet["Y"*string(number + 1)] = parse(Float64, split(lines[24], " ")[end][1:end-1])
                sheet["Z"*string(number + 1)] = parse(Int64, split(lines[25], " ")[end])
                sheet["AA"*string(number + 1)] = parse(Float64, split(lines[26], " ")[end])
                sheet["AB"*string(number + 1)] = parse(Float64, split(lines[27], " ")[end])
                sheet["AC"*string(number + 1)] = parse(Float64, split(lines[28], " ")[end])
                sheet["AD"*string(number + 1)] = parse(Float64, split(lines[29], " ")[end][1:end-1])
            end
        end
    end
end

function read_heuristic_opticlass(xfile::String, datafile::String, ligne::Int64)
    file_name = split(datafile, ('_', '.', '/'))
    data_type = string(file_name[5])
    number = join(file_name[7:end-1], "_")
    XLSX.openxlsx(xfile, mode="rw") do xf
        if data_type ∉ XLSX.sheetnames(xf)
            sheet = XLSX.addsheet!(xf, data_type)
            sheet["A1"] = "Instance"
            sheet["B1"] = "Objective value"
            sheet["C1"] = "Pourcentage"
            sheet["D1"] = "Décroissance"
            sheet["E1"] = "Nombre d'itération stagnante"
            sheet["F1"] = "Nombre d'itération améliorante 1"
            sheet["G1"] = "f1 1"
            sheet["H1"] = "f2 1"
            sheet["I1"] = "f3 1"
            sheet["J1"] = "Time 1"
            sheet["K1"] = "Nombre d'itération améliorante 2"
            sheet["L1"] = "f1 2"
            sheet["M1"] = "f2 2"
            sheet["N1"] = "f3 2"
            sheet["O1"] = "Time 2"
            sheet["P1"] = "Nombre d'itération améliorante 3"
            sheet["Q1"] = "f1 3"
            sheet["R1"] = "f2 3"
            sheet["S1"] = "f3 3"
            sheet["T1"] = "Time 3"
            sheet["U1"] = "Nombre d'itération améliorante 4"
            sheet["V1"] = "f1 4"
            sheet["W1"] = "f2 4"
            sheet["X1"] = "f3 4"
            sheet["Y1"] = "Time 4"
            sheet["Z1"] = "Nombre d'itération améliorante 5"
            sheet["AA1"] = "f1 5"
            sheet["AB1"] = "f2 5"
            sheet["AC1"] = "f3 5"
            sheet["AD1"] = "Time 5"
        else
            sheet = xf[data_type]
        end
        open(datafile) do f
            lines = readlines(f)
            sheet["A"*string(ligne + 1)] = string(number)
            sheet["B"*string(ligne + 1)] = parse(Float64, split(lines[1], " ")[end])
            sheet["C"*string(ligne + 1)] = parse(Float64, split(lines[2], " ")[end])
            sheet["D"*string(ligne + 1)] = parse(Float64, split(lines[3], " ")[end])
            sheet["E"*string(ligne + 1)] = parse(Int64, split(lines[4], " ")[end])
            sheet["F"*string(ligne + 1)] = parse(Int64, split(lines[5], " ")[end])
            sheet["G"*string(ligne + 1)] = parse(Float64, split(lines[6], " ")[end])
            sheet["H"*string(ligne + 1)] = parse(Float64, split(lines[7], " ")[end])
            sheet["I"*string(ligne + 1)] = parse(Float64, split(lines[8], " ")[end])
            sheet["J"*string(ligne + 1)] = parse(Float64, split(lines[9], " ")[end][1:end-1])
            sheet["K"*string(ligne + 1)] = parse(Int64, split(lines[10], " ")[end])
            sheet["L"*string(ligne + 1)] = parse(Float64, split(lines[11], " ")[end])
            sheet["M"*string(ligne + 1)] = parse(Float64, split(lines[12], " ")[end])
            sheet["N"*string(ligne + 1)] = parse(Float64, split(lines[13], " ")[end])
            sheet["O"*string(ligne + 1)] = parse(Float64, split(lines[14], " ")[end][1:end-1])
            sheet["P"*string(ligne + 1)] = parse(Int64, split(lines[15], " ")[end])
            sheet["Q"*string(ligne + 1)] = parse(Float64, split(lines[16], " ")[end])
            sheet["R"*string(ligne + 1)] = parse(Float64, split(lines[17], " ")[end])
            sheet["S"*string(ligne + 1)] = parse(Float64, split(lines[18], " ")[end])
            sheet["T"*string(ligne + 1)] = parse(Float64, split(lines[19], " ")[end][1:end-1])
            sheet["U"*string(ligne + 1)] = parse(Int64, split(lines[20], " ")[end])
            sheet["V"*string(ligne + 1)] = parse(Float64, split(lines[21], " ")[end])
            sheet["W"*string(ligne + 1)] = parse(Float64, split(lines[22], " ")[end])
            sheet["X"*string(ligne + 1)] = parse(Float64, split(lines[23], " ")[end])
            sheet["Y"*string(ligne + 1)] = parse(Float64, split(lines[24], " ")[end][1:end-1])
            sheet["Z"*string(ligne + 1)] = parse(Int64, split(lines[25], " ")[end])
            sheet["AA"*string(ligne + 1)] = parse(Float64, split(lines[26], " ")[end])
            sheet["AB"*string(ligne + 1)] = parse(Float64, split(lines[27], " ")[end])
            sheet["AC"*string(ligne + 1)] = parse(Float64, split(lines[28], " ")[end])
            sheet["AD"*string(ligne + 1)] = parse(Float64, split(lines[29], " ")[end][1:end-1])
        end
    end
end

# target = "../resultsheuristique/"
# fnames = getfname(target)
# global numero_ligne = 1

# for names in fnames
#     if split(names, "_" )[1] == "OPTICLASS"
#         read_heuristic_opticlass("heuristic_results.xlsx", target*names, numero_ligne)
#         global numero_ligne += 1
#     # else
#     #     read_heuristic("heuristic_results.xlsx", target*names)
#     end
# end

# readfile_results("../results/12_20_[1,6]_1700_1.txt")

# read_heuristic("heuristic_results.xlsx", "../resultsheuristique/OPTICLASS_trafic_05_24_PF_3_2.txt")
