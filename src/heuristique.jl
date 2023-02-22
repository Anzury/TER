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
function neighbour(instance::Matrix,τ)
    #initialisation
    s0 = instance
    i = 0
    r = 1
    s = s0
    #compute the most loaded output
    k = 0
    for j in 1:size(s0)[2]
        if s0[r,j] > k
            k = s0[r,j]
        end
    end
    #compute the set of direct left empty outputs of the non-empty output k in round r of solution s
    Oleft = []
    for j in 1:size(s0)[2]
        if s0[r,j] == k-1
            push!(Oleft,j)
        end
    end
    #compute the set of direct right empty outputs of the non-empty output k in round r of solution s
    Oright = []
    for j in 1:size(s0)[2]
        if s0[r,j] == k+1
            push!(Oright,j)
        end
    end
    #if O(r,k)→ (s(i)) ̸= ∅, then choose the least loaded output q ∈O(r,k)→ (s(i)) and go to Step 4.
    if Oright != []
        q = minimum(Oright)
        #Let s(T ) be a solution obtained from solution s(i) by shifting the mail batch from output k to output q for round r.
        sT = s0
        sT[r,q] = k
        sT[r,k] = k+1
        #If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
        if f(sT) < f(s0) + τ
            i = i+1
            s = sT
        end
    #if O(r,k)← (s(i)) ̸= ∅, then choose the least loaded output q ∈O(r,k)← (s(i)), otherwise go to Step 5.
    elseif Oleft != []
        q = minimum(Oleft)
        #Let s(T ) be a solution obtained from solution s(i) by shifting the mail batch from output k to output q for round r.
        sT = s0
        sT[r,q] = k
        sT[r,k] = k-1
        #If f(s(T )) < f(s(i)) + τ, then move to a new current solution, i.e., set i := i + 1 and s(i) := s(T ).
        if f(sT) < f(s0) + τ
            i = i+1
            s = sT
        end
    end
    #if r < |R|, then set r := r + 1 and go to Step 2. Otherwise, stop and return solution s(i).
    if r < size(s0)[1]
        r = r+1
        neighbour(s,τ)
    else
        return s
    end
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
function heuristique(instance::Matrix)
    # Stage 1
    # 1.1
    τ = 0
    s = instance
    s_best = instance
    # 1.2
    s_star = neighbour(s,τ)
    if f(s_star) < f(s)
        s = s_star
        s_best = s_star
        s_star = neighbour(s,τ)
    end
    # Stage 2
    # 2.1
    τ = 0.05*f(s)
    ∆ = 0.02
    # 2.2
    s_star = neighbour(s,τ)
    if f(s_star) < f(s_best)
        s_best = s_star
    end
    if f(s_star) < f(s)
        s = s_star
        s_star = neighbour(s,τ)
    end
    # 2.3
    τ = τ - ∆
    s = s_star
    if τ > 0
        s_star = neighbour(s,τ)
        if f(s_star) < f(s_best)
            s_best = s_star
        end
        if f(s_star) < f(s)
            s = s_star
            s_star = neighbour(s,τ)
        end
    end
    # Stage 3
    # 3.1
    τ = 0
    # 3.2
    s_star = neighbour(s,τ)
    if f(s_star) < f(s_best)
        s_best = s_star
    end
    if f(s_star) < f(s)
        s = s_star
        s_star = neighbour(s,τ)
    end
    return s_best
end