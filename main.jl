# ==============================================================================
# mainBB1D.jl
# X. Gandibleux - Novembre 2022
# Modifié par PICHON Adrien et MARCHAND Aurelien - Novembre 2022

using JuMP
using GLPK
using Gurobi
using MathOptInterface

# include("model.jl")
include("datastructMILP.jl")
include("loadinstance.jl")

"""
    main(fname)

    Main entry point of the method, run method on the instances stored in `fname`.

    # Arguments
    - `fname`: the filename of the file containing the instance.
"""
function main(fname::String)
    data::instanceMILP = loadinstanceMILP("InstancesPoste/InstancesPoste/" * fname)
    io = open("geek.txt","w")
    println(io,data)
    close(io)

        # println(instance.id)
        # MILP, x, y = modelMILP(Gurobi.Optimizer, instance, length(instance.w), true, true)
        # println("\nOptimisation...")
        # optimize!(MILP)
        # println("\nRésultats")
        # println(solution_summary(MILP))

    return nothing
end

main("120_90/120_90_[1,4]_4100_1.xlsx")
