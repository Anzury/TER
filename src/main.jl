using JuMP
using GLPK
using Gurobi
using MathOptInterface

include("model.jl")
include("datastructMILP.jl")
include("loadinstance.jl")
include("heuristique.jl")
include("heuristique2.jl")
include("heuristique3.jl")
include("heuristique4.jl")
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

    nbsolopti = 0
    nbsolacceptable = 0
    targetfolder = "../data/data_reelles/"
    folder = getfname(targetfolder)
    for file in folder

            # target = "../data/100_60/100_60_[1,4]_3300_3.xlsx"
            # target = "../data/30_30/30_30_[1,6]_2400_1.xlsx"
            # target = "../data/75_50/75_50_[1,5]_3300_1.xlsx"
            # target = "../data/120_90/120_90_[1,4]_4100_1.xlsx"
            # target = "../data/data_reelles/OPTICLASS_trafic_05_24_PF.xlsx"
            # target = "../data/data_reelles/OPTICLASS_trafic_06_27_PF.xlsx"
            # target = "../data/12_20/12_20_[1,6]_1700_2.xlsx"
            target = targetfolder * file

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

            data = loadinstance(target)
            # data = loadinstance(string(target, folder[1], "/", files))

            println("id: ",file[1:end-5])
            # id = basename(string(target, folder[1], "/", files)[1:end-5])
            # println("id: ",id)

            fonctionobjectif = 3
            pourcentage = 0.035
            decroissance = 0.02
            nbiterstagnant = 35
            nbiterameliore = typemax(Int64)
            # nbiterameliore = 10

            io = stdout
            io = open("../resultsfinauxopticlass/" * file[1:end-5] * ".txt", "w")

            println(io,"id: ",file[1:end-5])
            println(io,"fonctionobjectif= f", fonctionobjectif)
            println(io,"pourcentage= ", pourcentage)
            println(io,"decroissance= ", decroissance)
            println(io,"nbiterstagnant= ", nbiterstagnant)
            println(io,"nbiterameliore= ", nbiterameliore)
            println(io,"taille matrice: ",size(data))
            
            t1 = @elapsed sol,solutions = heuristique3(data,io,fonctionobjectif,pourcentage,decroissance,nbiterstagnant,nbiterameliore)
            println(io,"Temps avec heuristique= ", t1,"s")
            # plotsolutions(solutions,f(3,sum(sol,dims=1)), target, fonctionobjectif, pourcentage, decroissance, nbiterstagnant, nbiterameliore)
            if f(1,sum(sol,dims=1)) <= 10
                nbsolopti += 1
            end
            if f(1,sum(sol,dims=1)) <= 50
                nbsolacceptable += 1
            end
            close(io)
        # end
    end
    fonctionobjectif = 3
    pourcentage = 0.035
    decroissance = 0.02
    nbiterstagnant = 35
    nbiterameliore = typemax(Int64)
    io = open("../resultsfinauxopticlass/" * "resultats.txt", "w")
    println(io,"Il y a ", length(folder), " instances")
    println(io,"fonctionobjectif utilisée pour optimiser: f", fonctionobjectif)
    println(io,"pourcentage de la solution initiale pour l'initialisation de tau = ", pourcentage)
    println(io,"valeur de décroissance de tau (delta) = ", decroissance)
    println(io,"nombre d'itérations non améliorantes pour arrêt de la phase 2 = ", nbiterstagnant)
    println(io,"nombre d'itérations avant l'alternation de phases pendant la phase 2 = ", nbiterameliore)
    if nbsolopti == length(folder)
        println(io,"Toutes les solutions sont optimales !!! (f1 <= 10)")
    else
        println(io,"Il y a ", nbsolopti, " solutions optimales (f1 <= 10) sur ", length(folder))
    end
    if nbsolacceptable == length(folder)
        println(io,"Toutes les solutions sont acceptables !!! (f1 <= 50)")
    else
        println(io,"Il y a ", nbsolacceptable, " solutions acceptables (f1 <= 50) sur ", length(folder))
    end
    close(io)
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

@time main()