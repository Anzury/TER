
struct interval
    debut::Int64
    fin::Int64
end

struct mailbatch
    batch::AbstractArray{Int64}
end

"""
    data structure for a MILP instance
"""
struct instanceMILP
    id :: String #id of instance
    R :: Int64 # number of all postmen’s rounds
    B :: AbstractArray{BitSet} #set of mail batches for the round r ∈ R
    V :: AbstractArray{mailbatch} #vj(r) is the volume of the j-th mail batch in the round
    O :: Int64 #number of outputs for the first mail sorting step
    Oj :: AbstractArray{AbstractArray{interval}} #interval of potential outputs for the j-th mail batch in the round r ∈ R
    U :: AbstractArray{AbstractArray{AbstractArray}} #set of mail bathes of round r, which can be potentially assigned to the output k ∈ O
    X :: AbstractArray{AbstractArray{AbstractArray{Bool}}} #equal to 1 if the j-th mail batch of round r is assigned to the output k ∈ O, 0 otherwise
    Lmin :: Int64 #minimal load per output
    Lmax :: Int64 #maximal load per output
end

