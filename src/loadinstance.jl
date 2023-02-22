using XLSX

"""
    Load a MILP instance from a XL file name.
"""
function loadinstanceMILP(xlfile::String)
    data = reduce(hcat,XLSX.readtable(xlfile, "matrice_init").data)
    sizeMILP = size(data)
    id::String = basename(xlfile)[1:end-5]
    R::Int64 = sizeMILP[1]-1
    O::Int64 = sizeMILP[2]-4

    B = []
    V = []
    Oj = []
    U = []
    X = []
    for i in 1:R
        # compute B and V
        batch = []
        k = 0
        for j in 5:sizeMILP[2]
            if data[i,j]!=0
                k+=1
                push!(batch,data[i,j])
            end
        end
        push!(B,BitSet(1:k))
        round = mailbatch(batch)
        push!(V,round)

        # Compute Oj
        intervalbatch = []
        for j in 1:k
            push!(intervalbatch,interval(j,sizeMILP[2]-4-(k-j)))
        end
        push!(Oj,intervalbatch)

        # Compute U
        outputs = []
        for j in 1:O
            mailset = []
            for l in 1:k
                if intervalbatch[l].debut <= j && intervalbatch[l].fin >= j
                    push!(mailset,l)
                end
            end
            push!(outputs,mailset)
        end
        push!(U,outputs)


        # compute X
        roundx = []
        for j in 1:k
            batchx = zeros(Bool,O)
            batchx[j] = true
            push!(roundx,batchx)
        end
        push!(X,roundx)

    end
    # initialise Lmin & Lmax
    Lmin = minimum(data[sizeMILP[1],5:sizeMILP[2]])
    Lmax = maximum(data[sizeMILP[1],5:sizeMILP[2]])
    
    return instanceMILP(id,R,B,V,O,Oj,U,X,Lmin,Lmax)
end

"""
    Load an instance from a XL file name.
"""
function loadinstance(xlfile::String)
    data = reduce(hcat,XLSX.readtable(xlfile, "matrice_init").data)
    data = data[1:end-1,5:end]
    return data
end