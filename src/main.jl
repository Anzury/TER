using JuMP
using GLPK
using Gurobi
using MathOptInterface

include("model.jl")
include("datastructMILP.jl")
include("loadinstance.jl")
# include("writeinstance.jl")
include("heuristique.jl")
include("plot.jl")

"""
    main(fname)

    Main entry point of the method, run method on the instances.

"""
function main()
    println("\nEtudiants : Adrien Pichon et Nicolas Compère\n")

    # Collecting the names of instances to solve located in the folder Data ----
    # target = "../data/"
    # fnames = getfname(target)

    # allfnames = []
    # for name in fnames
    #     push!(allfnames, [name, getfname(string(target, "/", name))])
    # end
    
    # println("")
    # for folder in allfnames
    #     for files in folder[2]
            # target = "../data/75_50/75_50_[1,5]_3300_1.xlsx"
            # data = loadinstanceMILP(string(target, folder[1], "/", files))
            # data = loadinstanceMILP(target)

            # id = data.id
            # println(id)
            # println("")
            # MILP = modelMILP(data, true, Gurobi.Optimizer)
            # println("\nOptimisation...")
            # optimize!(MILP)
            # println("\nRésultats")
            # println(solution_summary(MILP))

            # io = open("./results/$id.txt", "w")
            # println(io, solution_summary(MILP, verbose=true))
            # close(io)

            # data = loadinstance(string(target, folder[1], "/", files))
            # target = "../data/100_60/100_60_[1,4]_3300_2.xlsx"
            # target = "../data/30_30/30_30_[1,6]_2400_1.xlsx"
            # target = "../data/75_50/75_50_[1,5]_3300_1.xlsx"
            target = "../data/120_90/120_90_[1,4]_4100_1.xlsx"
            # target = "../data/data_reelles/OPTICLASS_trafic_05_24_PF.xlsx"
            # target = "../data/12_20/12_20_[1,6]_1700_1.xlsx"
            data = loadinstance(target)
            # println("id: ",basename(string(target, folder[1], "/", files)[1:end-5]))
            println("id: ",basename(target)[1:end-5])
            t = @elapsed sol,solutions = heuristique(data,3,0.2,0.02,500)
            println("Temps: ", t)
            plotsolutions(solutions, target)
    #     end
    # end

    return nothing
end

function getfname(pathtofolder)

    # recupere tous les fichiers se trouvant dans le repertoire cible
    allfiles = readdir(pathtofolder , sort = false)

    # vecteur booleen qui marque les noms de fichiers valides
    flag = trues(size(allfiles))

    k = 1
    for f in allfiles
        # traite chaque fichier du repertoire
        if f[1] != '.'
            # pas un fichier cache => conserver
            println("fname = ", f)
        else
            # fichier cache => supprimer
            flag[k] = false
        end
        k = k + 1
    end

    # extrait les noms valides et retourne le vecteur correspondant
    finstances = allfiles[flag]
    return finstances
end

main()