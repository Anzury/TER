using XLSX

"""
    Load a MILP instance from a XL file name.
"""
function loadinstanceMILP(xlfile::String)
    data = reduce(hcat,XLSX.readtable(xlfile, "matrice_init").data)
    sizeMILP = size(data)
    id::String = xlfile
    R::Set{Int64} = BitSet(1:(sizeMILP[1]-1))