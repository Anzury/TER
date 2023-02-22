using JuMP
using GLPK
using Gurobi
using MathOptInterface

include("model.jl")
include("datastructMILP.jl")
include("loadinstance.jl")
# include("writeinstance.jl")
include("heuristique.jl")

"""
    main(fname)

    Main entry point of the method, run method on the instances stored in `fname`.

    # Arguments
    - `fname`: the filename of the file containing the instance.
"""
function main()
    println("\nEtudiants : Adrien Pichon et Nicolas Compère\n")

    # Collecting the names of instances to solve located in the folder Data ----
    target = "../data/"
    fnames = getfname(target)

    allfnames = []
    for name in fnames
        push!(allfnames, [name, getfname(string(target, "/", name))])
    end
    
    println("")
    for folder in allfnames
        for files in folder[2]
            # data = loadinstanceMILP(string(target, folder[1], "/", files))

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

            data = loadinstance(string(target, folder[1], "/", files))
            println("id: ",basename(string(target, folder[1], "/", files)[1:end-5]))
            sol = heuristique(data)
            println("Solution: ", f(sol))
        end
    end

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