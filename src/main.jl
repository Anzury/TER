using JuMP
using GLPK
using Gurobi
using MathOptInterface

include("model.jl")
include("datastructMILP.jl")
include("loadinstance.jl")
# include("writeinstance.jl")
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

            # target = "../data/100_60/100_60_[1,4]_3300_3.xlsx"
            target = "../data/30_30/30_30_[1,6]_2400_1.xlsx"
            # target = "../data/75_50/75_50_[1,5]_3300_1.xlsx"
            # target = "../data/120_90/120_90_[1,4]_4100_1.xlsx"
            # target = "../data/data_reelles/OPTICLASS_trafic_05_24_PF.xlsx"
            # target = "../data/data_reelles/OPTICLASS_trafic_06_27_PF.xlsx"
            # target = "../data/12_20/12_20_[1,6]_1700_1.xlsx"

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

            # data = loadinstance(target)
            # data = loadinstance(string(target, folder[1], "/", files))

            # println("id: ",basename(target)[1:end-5])
            # id = basename(string(target, folder[1], "/", files)[1:end-5])
            # println("id: ",id)
            # id = basename(target)[1:end-5]

            # fonctionobjectif = 3
            # pourcentage = 0.05
            # decroissance = 0.002
            # nbiterstagnant = 50

            # io = open("../findbestpara.txt", "w")
            # io = stdout

            # println(io,"fonctionobjectif= f", fonctionobjectif)
            # println(io,"pourcentage= ", pourcentage)
            # println(io,"decroissance= ", decroissance)
            # println(io,"nbiterstagnant= ", nbiterstagnant)
            # println(io,"taille matrice: ",size(data))

            # resultstest = []
            # for target in ["../data/12_20/12_20_[1,6]_1700_1.xlsx","../data/30_30/30_30_[1,6]_2400_1.xlsx","../data/75_50/75_50_[1,5]_3300_1.xlsx","../data/100_60/100_60_[1,4]_3300_3.xlsx","../data/120_90/120_90_[1,4]_4100_1.xlsx","../data/data_reelles/OPTICLASS_trafic_05_24_PF.xlsx","../data/data_reelles/OPTICLASS_trafic_06_27_PF.xlsx"]
            #     println(io,"id: ",basename(target)[1:end-5])
            #     data = loadinstance(target)
            #     println(io,"taille matrice: ",size(data))
            #     matricesolutions = []
            #     for pourcentage in [0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5]
            #         println(io,"pourcentage= ", pourcentage)
            #         for decroissance in [0.002,0.004,0.006,0.008,0.01,0.012,0.014,0.016,0.018,0.02,0.022,0.024,0.026,0.028,0.03]
            #             println(io,"decroissance= ", decroissance)
            #             for nbiterameliore in [typemax(Int64)]
            #                 # println("nbiterameliore= ", nbiterameliore)
            #                 println(io,"nbiterameliore= ", nbiterameliore)
            #                 t1 = @elapsed sol,solutions = heuristique3(data,io,fonctionobjectif,pourcentage,decroissance,nbiterstagnant,nbiterameliore)
            #                 push!(matricesolutions, (sol,decroissance,pourcentage))
            #                 # println("Temps avec heuristique: ", t1,"s")
            #                 println(io,"Temps= ", t1,"s")
            #                 # plotsolutions(solutions,f(3,sum(sol,dims=1)), target, fonctionobjectif, pourcentage, decroissance, nbiterstagnant, nbiterameliore)
            #             end
            #         end
            #     end
            #     vaulesf3 = [f(3,sum(matricesolutions[i][1],dims=1)) for i in 1:lastindex(matricesolutions)]
            #     min = minimum(vaulesf3)
            #     meilleurssolutions = findall(x->x==min, vaulesf3)
            #     resultssize::AbstractArray{Tuple{Float64,Float64}} = [size(data)]
            #     for i in meilleurssolutions
            #         push!(resultssize,(matricesolutions[i][2],matricesolutions[i][3]))
            #     end
            #     push!(resultstest,resultssize)
            # end
            # io = open("../findbestpara.txt", "w")
            # println(io,"resultstest= ", resultstest)
            # for nbiterameliore in [10,typemax(Int64)]
            #     # println("nbiterameliore= ", nbiterameliore)
            #     println(io,"nbiterameliore= ", nbiterameliore)
            #     t1 = @elapsed sol,solutions = heuristique3(data,io,fonctionobjectif,pourcentage,decroissance,nbiterstagnant,nbiterameliore)
            #     # println("Temps avec heuristique: ", t1,"s")
            #     println(io,"Temps= ", t1,"s")
            #     plotsolutions(solutions,f(3,sum(sol,dims=1)), target, fonctionobjectif, pourcentage, decroissance, nbiterstagnant, nbiterameliore)
            # end
            # close(io)
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

@time main()