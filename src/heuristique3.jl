using Statistics
"""
Function neighbour3(instance::Matrix, τ)
Input: An initial solution s(0) and a tolerance value τ.
Output: A potentially new solution better than s(0).
1. Set i := 0 and r := 1.
2. let q be the least loaded output among the empty batches in round r of solution s(i). let k be the most loaded output among the non-empty batches in round r of solution s(i).
3. obtain s(T) by moving the empty batch from output q to output k in round r of solution s(i) and update the solution s(i) by shifting the non-empty batch between outputs k and q.
4. If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
5. If r < |R|, then set r := r + 1 Otherwise, stop and return solution s(i).
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
            println("outputsload :",outputsload)
        end
        # let q be the least loaded output among the empty batches in round r of solution s(i)
        #compute the empty outputs in round r
        emptyoutputs = findall(x->x==0,vec(s[r,:]))
        if isempty(emptyoutputs)
            continue
        end
        q = emptyoutputs[argmin(outputsload[emptyoutputs])]
        if verbose
            println("least loaded output q: ",q)
        end

        # let k be the most loaded output among the non-empty batches in round r of solution s(i)
        #compute the non-empty outputs in round r
        nonemptyoutputs = findall(x->x!=0,vec(s[r,:]))
        if isempty(nonemptyoutputs)
            continue
        end
        k = nonemptyoutputs[argmax(outputsload[nonemptyoutputs])]
        if verbose
            println("most loaded output k: ",k)
        end

        # obtain s(T) by moving the empty batch from output q to output k in round r of solution s(i) 
        # and update the solution s(i) by shifting the non-empty batch between outputs k and q.
        #compute the movement on outputsload
        rotation = sign(q-k)
        shiftingoutputs = []
        if rotation == 1
            for j in k:q
                if j == q || s[r,j] != 0
                    push!(shiftingoutputs,j)
                end
            end
        elseif rotation == -1
            for j in q:k
                if j == q || s[r,j] != 0
                    push!(shiftingoutputs,j)
                end
            end
        else
            println("error rotation != -1/1")
        end
        if verbose
            println("shifting outputs: ",shiftingoutputs)
        end
        oldoutputsload = deepcopy(outputsload)
        for j in shiftingoutputs
            outputsload[j] -= s[r,j]
        end
        shiftedoutputs = circshift(shiftingoutputs,rotation)
        for j in 1:lastindex(shiftingoutputs)
            s[r,shiftingoutputs[j]] = instance[r,shiftedoutputs[j]]
            outputsload[shiftingoutputs[j]] += s[r,shiftingoutputs[j]]
        end
        if f(objfunc,outputsload) < f(objfunc,oldoutputsload) + τ   
            if verbose
                println("new solution found")
                println("new round: ",s[r,:])
            end
            continue
        else
            if verbose
                println("no new solution found")
            end
            for j in 1:lastindex(outputsload)
                outputsload[j] = oldoutputsload[j]
            end
            for j in 1:size(s0)[2]
                s[r,j] = instance[r,j]
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
function heuristique3(instance::Matrix,iomain = stdout,objfunc::Int64 = 3,pourcentage::Float64 = 0.05,∆::Float64 = 0.002,nbiterstagnanmax::Int64 = 50,iteramelio::Int64 = 10,verbose::Bool=false)
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
                    s_star,loads_s_star = neighbour3(s,loads_s,tempτ,objfunc,verbose,sortedrounds)
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
            if nbiterstagnanmax2 == 0
                # println("stagnation")
            end
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

    # println("nombre de while :",nombrewhile)
    # println("nombre de while 1.2 :",nbwhile12)
    # println("nombre de while 2.2 :",nbwhile22)
    # println("nombre de while 2.3 :",nbwhile23)
    # println("nombre de pause degrad :",nbpausedegrad)
    # println("nombre de while pause degrad :",nbwhilepausedegrad)
    # println("nombre de while 3.2 :",nbwhile32)
    # println("nombre de tau :",nbtau)

    # println("value avec f1 :",f1(loads_s_best))
    println(iomain,"f1= ",f1(loads_s_best))
    # println("value avec f2 :",f2(loads_s_best))
    println(iomain,"f2= ",f2(loads_s_best))
    # println("value avec f3 :",f3(loads_s_best))
    println(iomain,"f3= ",f3(loads_s_best))

    # display(s_best)
    # println(sum(s_best,dims=1))
    # println(loads_s_best)
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
    return sqrt(sum((Ck .- C).^2)/length(loads))
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
