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
function main()
    println("\nEtudiants : Adrien Pichon et Nicolas Compère\n")

    # Collecting the names of instances to solve located in the folder Data ----
    target = "./InstancesPoste/InstancesPoste/12_20/"
    fnames = getfname(target)

    println("")
    for instance in fnames
    
        data = loadinstanceMILP(string(target,"/",instance))

        id = data.id
        println(id)
        println("")
        MILP = modelMILP(data, true, Gurobi.Optimizer)
        println("\nOptimisation...")
        optimize!(MILP)
        println("\nRésultats")
        println(solution_summary(MILP))

        io = open("results/$id.txt","w")
        println(io,solution_summary(MILP, verbose = true))
        close(io)
    end

    return nothing
end

function getfname(pathtofolder)

    # recupere tous les fichiers se trouvant dans le repertoire cible
    allfiles = readdir(pathtofolder)

    # vecteur booleen qui marque les noms de fichiers valides
    flag = trues(size(allfiles))

    k=1
    for f in allfiles
        # traite chaque fichier du repertoire
        if f[1] != '.'
            # pas un fichier cache => conserver
            println("fname = ", f)
        else
            # fichier cache => supprimer
            flag[k] = false
        end
        k = k+1
    end

    # extrait les noms valides et retourne le vecteur correspondant
    finstances = allfiles[flag]
    return finstances
end

main()