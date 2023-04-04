using XLSX
using Statistics

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
    mail_batch::Int64, post_round::Int64, output::Int64 = 0, 0, 0
    # compute X
    file_name = basename(file)
    println(file_name)
    excel_name = file_name[1:end-4] * ".xlsx"
    type_tmp = split(file_name, "_")
    type = type_tmp[1] * "_" * type_tmp[2]
    data = loadinstanceMILP("../data/$type/$excel_name")
    X = data.X
    V = data.V
    open(file) do f
        lines = readlines(f)
        for i in 20:length(lines)-7
            words = split(lines[i], (',', ':', '[', ']', ' '))
            post_round = parse(Int64, words[6])
            mail_batch = parse(Int64, words[7])
            output = parse(Int64, words[8])
            x = round(parse(Float64, words[end]))
            X[post_round][mail_batch][output] = x
        end
    end
    # Remake the matrix with the results in X
    # initial_x = loadinstance("../data/$type/$excel_name")
    final_x = zeros(Int64, size(initial_x)[1], size(initial_x)[2])
    for r in 1:lastindex(X, 1)
        for j in 1:lastindex(X[r], 1)
            for k in 1:lastindex(X[r][j])
                final_x[r,k] += X[r][j][k] * V[r].batch[j]
            end
        end
    end
    return sum(final_x, dims=1)
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
            sheet["B1"] = "Fonction objectif"
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
        end
    end
end

function excel_MILP(xfile::String, datafile::String)
    file_name = split(datafile, ('_', '.', '/'))
    data_type = file_name[5] * "_" * file_name[6]
    number = parse(Int64, file_name[end-1])
    if !isfile(xfile)
        XLSX.openxlsx(xfile, mode="w") do xf
            sheet = xf[1]
            XLSX.rename!(sheet, data_type)
            sheet["A1"] = "Instance"
            sheet["B1"] = "f1"
            sheet["C1"] = "f2"
            sheet["D1"] = "f3"
            sheet["A"*string(number + 1)] = string(number)
            sheet["B"*string(number + 1)] = f1(readfile_results(datafile))
            sheet["C"*string(number + 1)] = f2(readfile_results(datafile))
            sheet["D"*string(number + 1)] = f3(readfile_results(datafile))
        end
    else
        XLSX.openxlsx(xfile, mode="rw") do xf
            if data_type ∉ XLSX.sheetnames(xf)
                sheet = XLSX.addsheet!(xf, data_type)
                sheet["A1"] = "Instance"
            sheet["B1"] = "f1"
            sheet["C1"] = "f2"
            sheet["D1"] = "f3"
            else
                sheet = xf[data_type]
            end
            sheet["A"*string(number + 1)] = string(number)
            sheet["B"*string(number + 1)] = f1(readfile_results(datafile))
            sheet["C"*string(number + 1)] = f2(readfile_results(datafile))
            sheet["D"*string(number + 1)] = f3(readfile_results(datafile))
        end
    end
end

function f1(loads)
    return maximum(loads) - minimum(loads)
end

"""
Ck = the sum of the batch for the output k
C* = the mean of the Ck for each outputs k
f(s) compute the sum of the difference between Ck and C* for each output k divided by the number of outputs
"""
function f2(loads)
    Ck = loads
    C = mean(Ck)
    return sum(abs.(Ck .- C))/length(loads)
end

"""
Ck = the sum of the batch for the output k
C* = the mean of the Ck for each outputs k
f(s) compute the square root of the sum of the difference between Ck and C* squared for each output k divided by the number of outputs
"""
function f3(loads)
    Ck = loads
    C = mean(Ck)
    return sqrt(sum((Ck .- C).^2))/length(loads)
end

target = "../resultsheuristiquesortedrounds/"
fnames = getfname(target)
global numero_ligne = 1

for names in fnames
    if names[1] == 'O'
        read_heuristic_opticlass("heuristic_results_V2.xlsx", target * names, numero_ligne)
        global numero_ligne += 1
    else
        read_heuristic("heuristic_results_V2.xlsx", target * names)
    end
end

# data = readfile_results("../results/12_20_[1,6]_1700_1.txt")
# display(data)

# loads = sum(data, dims=1)

# println(f1(data))
# println(f2(data))
# println(f3(data))

# read_heuristic("heuristic_results.xlsx", "../resultsheuristique/OPTICLASS_trafic_05_24_PF_3_2.txt")
# excel_MILP("MILP_results.xlsx", "../results/12_20_[1,6]_1700_1.txt")