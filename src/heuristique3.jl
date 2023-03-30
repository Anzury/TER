using Statistics
"""
Function neighbour(instance::Matrix, τ)
Input: An initial solution s(0) and a tolerance value τ.
Output: A potentially new solution better than s(0).
1. Set i := 0 and r := 1.
2. Let k be the most loaded output among the non-empty ones of round r for solution s(i). If O(r,k)→ (s(i)) ̸= ∅, then
choose the least loaded output q ∈O(r,k)→ (s(i)) and go to Step 4.
3. If O(r,k)← (s(i)) ̸= ∅, then choose the least loaded output q ∈O(r,k)← (s(i)), otherwise go to Step 5.
4. Let s(T ) be a solution obtained from solution s(i) by shifting the mail batch from output k to output q for round
r. If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
5. If r < |R|, then set r := r + 1 and go to Step 2. Otherwise, stop and return solution s(i).
• O(r,k)← (s) is the set of direct left empty outputs of the
non-empty output k in round r of solution s.
• O(r,k)→ (s) is the set of direct right empty outputs of
the non-empty output k in round r of solution s.
"""
function neighbour3(instance::Matrix,outputs,τ,objfunc::Int64,verbose::Bool=false,roundsorder=1:size(s0)[1])
    #initialisation
    s0 = instance
    i = 0
    r = 1
    s = deepcopy(instance)
    outputsload = deepcopy(outputs)
    for r in roundsorder
        if verbose
            println("round r = ",r)
            println("round :",s[r,:])
        end
        # compute the batches of round r that can be mouved and the most loaded
        # output among the movables batches
        movables = []
        maxLoad, k = -1, -1
        for j = 1:size(s0)[2]
            if s[r,j] != 0 && ((j+1<=size(s0)[2] && s[r,j+1]==0) || (j-1>=1 && s[r,j-1]==0))
                push!(movables,j)
                if outputsload[j] > maxLoad
                    maxLoad, k = outputsload[j], j
                end
            end
        end
        if k == -1
            continue
        end
        if verbose
            println("movables batches: ",movables)
        end
        if verbose
            println("most loaded output k: ",k)
        end

        #compute the set of direct left empty outputs of the non-empty output k in round r of solution s
        moves, ridx, lidx = [], -1, -1
        if k < size(s0)[2]
            j = k + 1
            while j <= size(s0)[2] && s[r,j] == 0
                push!(moves,j)
                if ridx == -1
                    ridx = j
                end
                j = j+1
            end
        end
        if k > 1
            j = k - 1
            while j >= 1 && s[r,j] == 0
                push!(moves,j)
                if lidx == -1
                    lidx = j
                end
                j = j-1
            end
        end

        minloadl, minloadr = typemax(Int64), typemax(Int64)
        idxminloadl, idxminloadr = -1, -1
        i = 1
        for idx in moves
            if ridx != -1 && idx >= ridx && minloadr > outputsload[idx]
                idxminloadr, minloadr = i, outputsload[idx]
            end
            if ridx == -1 && lidx != -1 && idx <= lidx && minloadl > outputsload[idx]
                idxminloadl, minloadl = i, outputsload[idx]
            end
            i = i+1
        end

        if minloadl < minloadr
            minloadr, idxminloadr = minloadl, idxminloadl
        end

        if idxminloadr != -1
        # if !isempty(moves)
            q = moves[idxminloadr]
            if verbose
                println("least loaded output q = ",q)
            end
            #Let s(T ) be a solution obtained from solution s(i) by shifting the mail batch from output k to output q for round r.
            val = f(objfunc,outputsload)
            outputsload[k] = outputsload[k] - s[r,k]
            outputsload[q] = outputsload[q] + s[r,k]
            #If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
            if f(objfunc,outputsload) < val + τ
                i = i+1
                s[r,q] = s[r,k]
                s[r,k] = 0
                if verbose
                    println("updated round sT = ",s[r,:])
                    println("f(sT) = ",f(objfunc,outputsload)," f(s) = ",val)
                end
            elseif verbose
                println("no update")
                outputsload[k] = outputsload[k] + s[r,k]
                outputsload[q] = outputsload[q] - s[r,k]
            else
                outputsload[k] = outputsload[k] + s[r,k]
                outputsload[q] = outputsload[q] - s[r,k]
            end
        end
    end
    return s,outputsload
end

"""
sort the rounds of a solution s by the number of non-empty outputs
"""
function sortrounds(s::Matrix)
    nrounds = size(s)[1]
    noutputs = size(s)[2]
    numberofmail = zeros(Int64,nrounds)
    for r in 1:nrounds
        for k in 1:noutputs
            if s[r,k] != 0
                numberofmail[r] = numberofmail[r] + 1
            end
        end
    end
    return sortperm(numberofmail, rev=true)
end

"""
Heuristic Opti-Move
Input: A current solution s.
Output: The best known solution s(B).
• Stage 1.
1.1. Set tolerance value τ := 0 and s(B) := s.
1.2. Let s∗ be a solution provided by the procedure
Neighbor(s,τ). If f(s∗) < f(s), then reset s :=
s∗, set s(B) := s∗ and repeat Step 1.2.
• Stage 2.
2.1. Set tolerance value τ := 0.05 ·f(s) and decrement
step ∆ := 0.02.
2.2. Let s∗ be a solution provided by the procedure
Neighbor(s,τ). If f(s∗) < f(s(B)), then set
s(B) := s∗. If f(s∗) < f(s), then reset s := s∗
and repeat Step 2.2.
2.3. Decrease the tolerance value τ := τ −∆ and reset
s := s∗. If τ > 0, then go to Step 2.2.
• Stage 3.
3.1. Set tolerance value τ := 0.
3.2. Let s∗ be a solution provided by the procedure
Neighbor(s,τ). If f(s∗) < f(s(B)), then set
s(B) := s∗. If f(s∗) < f(s), then reset s := s∗
and repeat Step 3.2. Otherwise, stop and return
the best found solution s(B).
"""
function heuristique3(instance::Matrix,iomain,objfunc::Int64,pourcentage::Float64,∆::Float64 = 0.02,nbiterstagnanmax::Int64 = 50,iteramelio::Int64 = 10,verbose::Bool=false)
    # sortperm = sortrounds(instance)
    # sortedrounds = collect(1:size(instance)[1])[sortperm]
    sortedrounds = 1:size(instance)[1]
    nombrewhile = 0
    if verbose
        println("sorted rounds: ",sortedrounds)
        println("stage 1")
    end
    # Stage 1
    # 1.1
    τ = 0
    s = deepcopy(instance)
    s_best = deepcopy(instance)
    loads_s = sum(s,dims=1)
    loads_s_star = deepcopy(loads_s)
    loads_s_best = deepcopy(loads_s)
    solutions = [f(objfunc,loads_s)]
    if verbose
        println("step 1.2")
    end
    # 1.2
    nbwhile12 = 0
    s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
    push!(solutions,f(objfunc,loads_s_star))
    aumoinuneiteration = false
    while !aumoinuneiteration || f(objfunc,loads_s_star) < f(objfunc,loads_s)
        aumoinuneiteration = true
        nbwhile12 = nbwhile12 + 1
        nombrewhile = nombrewhile + 1
        s = s_star
        loads_s = loads_s_star
        s_best = s_star
        loads_s_best = loads_s_star
        s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
    end
    push!(solutions,f(objfunc,loads_s_best))
    if verbose
        println("stage 2")
    end
    # Stage 2
    # 2.1
    τ = pourcentage*f(objfunc,loads_s_best)
    if verbose
        println("valeur τ initialisé :",τ)
    end
    if verbose
        println("step 2.2")
    end
    # 2.2
    nbwhile22 = 0
    s_star,loads_s_star = neighbour3(s_star,loads_s_star,τ,objfunc,verbose,sortedrounds)
    aumoinuneiteration = false
    while !aumoinuneiteration || f(objfunc,loads_s_star) < f(objfunc,loads_s)
        aumoinuneiteration = true
        nbwhile22 = nbwhile22 + 1
        nombrewhile = nombrewhile + 1
        if verbose
            println("solution améliorée")
        end
        s = s_star
        loads_s = loads_s_star
        s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
        push!(solutions,f(objfunc,loads_s_star))
    end
    if f(objfunc,loads_s_star) < f(objfunc,loads_s_best)
        s_best = s_star
        loads_s_best = loads_s_star
    end
    push!(solutions,f(objfunc,loads_s_best))
    if verbose
        println("step 2.3")
    end
    # 2.3
    nbwhile23 = 0
    nbwhilepausedegrad = 0
    nbpausedegrad = 0
    nbtau = 1
    nbiterstagnanmax2 = nbiterstagnanmax
    τ = τ - ∆
    tempτ = 0
    s = s_star
    loads_s = loads_s_star
    pausedegrad = iteramelio
    while τ > 0 && nbiterstagnanmax2 > 0
        nbtau = nbtau + 1
        s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
        aumoinuneiteration = false
        while !aumoinuneiteration || f(objfunc,loads_s_star) < f(objfunc,loads_s)
            pausedegrad = pausedegrad - 1
            aumoinuneiteration = true
            nbwhile23 = nbwhile23 + 1
            nombrewhile = nombrewhile + 1
            if verbose
                println("solution améliorée")
            end
            s = s_star
            loads_s = loads_s_star
            s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
            if pausedegrad == 0
                nbpausedegrad = nbpausedegrad + 1
                aumoinuneiteration = false
                s_star,loads_s_star = neighbour3(s,loads_s,tempτ,objfunc,verbose,sortedrounds)
                while !aumoinuneiteration || f(objfunc,loads_s_star) < f(objfunc,loads_s)
                    aumoinuneiteration = true
                    nbwhilepausedegrad = nbwhilepausedegrad + 1
                    nombrewhile = nombrewhile + 1
                    s = s_star
                    loads_s = loads_s_star
                    s_star,loads_s_star = neighbour(s,loads_s,tempτ,objfunc,verbose,sortedrounds)
                    push!(solutions,f(objfunc,loads_s_star))
                end
                pausedegrad = iteramelio
            end
            push!(solutions,f(objfunc,loads_s_star))
            if f(objfunc,loads_s_star) < f(objfunc,loads_s_best)
                s_best = s_star
                loads_s_best = loads_s_star
                nbiterstagnanmax2 = nbiterstagnanmax
            end
            nbiterstagnanmax2 = nbiterstagnanmax2 - 1
        end
        τ = τ - ∆
        if verbose
            println("valeur τ changée :",τ)
        end

    end
    push!(solutions,f(objfunc,loads_s_best))
    if verbose
        println("stage 3")
    end
    # Stage 3
    # 3.1
    τ = 0
    if verbose
        println("step 3.2")
    end
    # 3.2
    nbwhile32 = 0
    s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
    aumoinuneiteration = false
    while !aumoinuneiteration || f(objfunc,loads_s_star) < f(objfunc,loads_s)
        aumoinuneiteration = true
        nbwhile32 = nbwhile32 + 1
        nombrewhile = nombrewhile + 1
        s = s_star
        loads_s = loads_s_star
        s_star,loads_s_star = neighbour3(s,loads_s,τ,objfunc,verbose,sortedrounds)
        push!(solutions,f(objfunc,loads_s_star))
    end
    if f(objfunc,loads_s_star) < f(objfunc,loads_s_best)
        s_best = s_star
        loads_s_best = loads_s_star
    end
    push!(solutions,f(objfunc,loads_s_best))
    println("nombre de while :",nombrewhile)
    println("nombre de while 1.2 :",nbwhile12)
    println("nombre de while 2.2 :",nbwhile22)
    println("nombre de while 2.3 :",nbwhile23)
    println("nombre de pause degrad :",nbpausedegrad)
    println("nombre de while pause degrad :",nbwhilepausedegrad)
    println("nombre de while 3.2 :",nbwhile32)
    println("nombre de tau :",nbtau)
    # println("value avec f1 :",f1(s_best))
    println(iomain,"f1= ",f1(loads_s_best))
    # println("value avec f2 :",f2(s_best))
    println(iomain,"f2= ",f2(loads_s_best))
    # println("value avec f3 :",f3(s_best))
    println(iomain,"f3= ",f3(loads_s_best))
    # display(s_best)
    # println(sum(s_best,dims=1))
    println(loads_s_best)
    return s_best,solutions
end

"""
compute the value of a solution s by summing the number of mails in each output and computing the difference between the maximum and the minimum
"""
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

function f(num::Int64,loads)
    if num == 1
        return f1(loads)
    elseif num == 2
        return f2(loads)
    elseif num == 3
        return f3(loads)
    end
end
