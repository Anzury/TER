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
function neighbour(instance::Matrix,τ,verbose::Bool=false)
    #initialisation
    s0 = instance
    i = 0
    r = 1
    s = deepcopy(s0)
    while r <= size(s0)[1]
        if verbose
            println("round r = ",r)
        end
        # compute the batches of round r that can be mouved
        movables = []
        for j = 1:size(s0)[2]
            if s[r,j] != 0 && ((j+1<=size(s0)[2] && s[r,j+1]==0) || (j-1>=1 && s[r,j-1]==0))
                push!(movables,j)
            end
        end
        if verbose
            println("movables batches: ",movables)
        end
        #compute the most loaded output among the non-empty ones of round r for solution s(i)
        if movables != []
            k,mostload = mostloadedoutput(s,movables,r)
        else
            if r < size(s0)[1]
                r = r+1
                continue
            else
                return s
            end
        end
        if verbose
            println("most loaded output k: ",k)
        end
        #compute the set of direct left empty outputs of the non-empty output k in round r of solution s
        Oright = []
        if k < size(s0)[2]
            j = k + 1
            while j <= size(s0)[2] && s[r,j] == 0
                    push!(Oright,j)
                    j = j+1
            end
        end
        if verbose
            println("moves possible to the right for batch in output k: ",Oright)
        end
        #compute the set of direct right empty outputs of the non-empty output k in round r of solution s
        Oleft = []
        if k > 1
            j = k - 1
            while j >= 1 && s[r,j] == 0
                    push!(Oleft,j)
                    j = j-1
            end
        end
        if verbose
            println("moves possible to the left for batch in output k: ",Oleft)
        end
        #if O(r,k)→ (s(i)) ̸= ∅, then choose the least loaded output q ∈O(r,k)→ (s(i)) and go to Step 4.
        if Oright != []
            q,leastload = leastloadedoutput(s,Oright)
            if verbose
                println("choose the least loaded output q ∈O(r,k)→ (s(i))")
                println("least loaded output q = ",q)
            end
            #Let s(T ) be a solution obtained from solution s(i) by shifting the mail batch from output k to output q for round r.
            sT = deepcopy(s)
            sT[r,q] = sT[r,k]
            sT[r,k] = 0
            #If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
            if f(sT) < f(s) + τ
                i = i+1
                s = sT
                if verbose
                    println("f(sT) = ",f(sT)," f(s) = ",f(s))
                    println("update s")
                end
            end
        #if O(r,k)← (s(i)) ̸= ∅, then choose the least loaded output q ∈O(r,k)← (s(i)), otherwise go to Step 5.
        elseif Oleft != []
            q,leastload = leastloadedoutput(s,Oleft)
            if verbose
                println("choose the least loaded output q ∈O(r,k)← (s(i))")
                println("least loaded output q = ",q)
            end
            #Let s(T ) be a solution obtained from solution s(i) by shifting the mail batch from output k to output q for round r.
            sT = deepcopy(s)
            sT[r,q] = sT[r,k]
            sT[r,k] = 0
            #If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
            if f(sT) < f(s) + τ
                i = i+1
                s = sT
                if verbose
                    println("f(sT) = ",f(sT)," f(s) = ",f(s))
                    println("update s")
                end
            end
        end
        #if r < |R|, then set r := r + 1 and go to Step 2. Otherwise, stop and return solution s(i).
        if r < size(s0)[1]
            r = r+1
        else
            return s
        end
    end
end

"""
compute the least loaded output of a solution s by finding the minimum of the sum of each column
"""
function leastloadedoutput(s::Matrix,set)
    min = sum(s[:,set[1]])
    output = set[1]
    for j in set[2:end]
        load = sum(s[:,j])
        if load < min
            min = load
            output = j
        end
    end
    return output, min
end

"""
compute the most loaded output of a solution among the non-empty ones of round r for solution s by finding the maximum of the sum of each column
"""
function mostloadedoutput(s::Matrix,set,r::Int64)
    max = sum(s[:,set[1]])
    output = set[1]
    for j in set[2:end]
        if s[r,j] != 0 
            load = sum(s[:,j])
            if load > max
                max = load
                output = j
            end
        end
    end
    return output, max
end

"""

"""


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
function heuristique(instance::Matrix,verbose::Bool=false)
    if verbose
        println("stage 1")
    end
    # Stage 1
    # 1.1
    τ = 0
    s = instance
    s_best = instance
    solutions = [f(s)]
    if verbose
        println("step 1.2")
    end
    # 1.2
    s_star = neighbour(s,τ)
    push!(solutions,f(s_star))
    while f(s_star) < f(s)
        s = deepcopy(s_star)
        s_best = s_star
        s_star = neighbour(s,τ)
    end
    push!(solutions,f(s_best))
    if verbose
        println("stage 2")
    end
    # Stage 2
    # 2.1
    τ = 0.05*f(s)
    ∆ = 0.5
    if verbose
        println("step 2.2")
    end
    # 2.2
    s_star = neighbour(s,τ)
    while f(s_star) < f(s)
        s = deepcopy(s_star)
        s_star = neighbour(s,τ)
        push!(solutions,f(s_star))
    end
    if f(s_star) < f(s_best)
        s_best = s_star
    end
    push!(solutions,f(s_best))
    if verbose
        println("step 2.3")
    end
    # 2.3
    τ = τ - ∆
    s = s_star
    while τ > 0
        s_star = neighbour(s,τ)
        while f(s_star) < f(s)
            s = deepcopy(s_star)
            s_star = neighbour(s,τ)
            push!(solutions,f(s_star))
        end
        τ = τ - ∆
    end
    if f(s_star) < f(s_best)
        s_best = s_star
    end
    push!(solutions,f(s_best))
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
    s_star = neighbour(s,τ)
    while f(s_star) < f(s)
        s = deepcopy(s_star)
        s_star = neighbour(s,τ)
        push!(solutions,f(s_star))
    end
    if f(s_star) < f(s_best)
        s_best = s_star
    end
    push!(solutions,f(s_best))
    return s_best,solutions
end

"""
compute the value of a solution s by summing the number of mails in each output and computing the difference between the maximum and the minimum
"""
function f(s)
    return maximum(sum(s,dims=1)) - minimum(sum(s,dims=1))
end
