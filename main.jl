using JuMP
using GLPK
using Gurobi
using MathOptInterface

include("model.jl")
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

    println(instance.id)
    MILP = modelMILP(Gurobi.Optimizer, instance, true)
    println("\nOptimisation...")
    optimize!(MILP)
    println("\nRésultats")
    println(solution_summary(MILP))

    return nothing
end

main("12_20/12_20_[1,6]_1700_1.xlsx")
