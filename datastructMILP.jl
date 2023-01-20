"""
    data structure for a MILP instance
"""

struct instanceMILP
    id :: String #id of instance
    R :: Set{Int64} # set of all postmen’s rounds
    B :: AbstractArray{Set{Int64}} #set of mail batches for the round r ∈ R
    V :: AbstractArray{Int64} #vj(r) is the volume of the j-th mail batch in the round
    O :: Set{Int64} #set of outputs for the first mail sorting step
    Oj :: AbstractArray{Int64} #interval of potential outputs for the j-th mail batch in the round r ∈ R
    U :: AbstractArray{Int64} #set of mail bathes of round r, which can be potentially assigned to the output k ∈ O
    X :: AbstractArray{Int64} #equal to 1 if the j-th mail batch of round r is assigned to the output k ∈ O, 0 otherwise
    Lmin :: Int64 #minimal load per output
    Lmax :: Int64 #maximal load per output
end
