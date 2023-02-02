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
    println(data)
        # println(instance.id)
        # MILP, x, y = modelMILP(Gurobi.Optimizer, instance, length(instance.w), true, true)
        # println("\nOptimisation...")
        # optimize!(MILP)
        # println("\nRésultats")
        # println(solution_summary(MILP))

    return nothing
end

main("12_20/12_20_[1,6]_1700_1.xlsx")
