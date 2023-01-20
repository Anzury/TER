using JuMP

"""
    modelMILP(solver, instance[, P1, binary])

    Create the bin packing model corresponding to _instance_ using
    `solver` as the optimizer. When `P1` is true we model against problem P1 (see
    report for further details), when `P1` is false we model against problem P2.
    If `binary` is true we consider boolean variables, if `binary` is false we consider
    free variables.

    # Arguments
    - `solver`: the solver Optimizer function.
    - `instance`: the bin packing instance.
    - **optional** `bound`: upper bound of m. By default, m = n.
    - **optional** `P1`: true if modeling with P1 (P2 otherwise and by default).
    - **optional** `binary`: true if modeling with binary variables (free variables otherwise).
"""
function modelMILP(solver = Gurobi.Optimizer, instanceMILP, binary::Bool = true)
    # Création du model
    m = direct_model((solver)())
    set_optimizer_attribute(m, "LogToConsole", 0)

    # Définition des variables
    @variable(m, 0 <= x[1:(n*m)] <= 1, binary=binary)
    @variable(m, 0 <= instanceMILP.Lmax)
    @variable(m, 0 <= instanceMILP.Lmin)

    # Définition de l'objectif (la somme des yj à minimiser)
    @objective(m, Min, instanceMILP.Lmax - instanceMILP.Lmin)

    # Définition des contraintes
    @constraint(m, [(j, r) in (instanceMILP.B[r], instanceMILP.R)], sum(x[r][j, k]) = 1 for k in instanceMILP.O[r][j]) # 2
    @constraint(m, [(k, r) in (instanceMILP.O, instanceMILP.R)], sum(x[r][j, k]) <= 1 for j in instanceMILP.U[r][k]) # 3
    @constraint(m, [(j, r) in (instanceMILP.B[r], instanceMILP.R)], sum(k * x[r][j, k] for k in O[r][j]) <= sum(k * x[r][j+1, k] for k in O[r][j+1])) # 4
    @constraint(m, [k in O], instanceMILP.Lmin <= sum(sum(v[r][j] * x[r][j, k] for j in instanceMILP.U[r][k]) for r in instanceMILP.R) <= InstanceMILP.Lmax) # 5

    return m
end
