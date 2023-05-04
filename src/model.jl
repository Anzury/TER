using JuMP

"""
    modelMILP(instance,binary,solver)

    Create the MILP model corresponding to _instance_ using
    `solver` as the optimizer. When `P1` is true we model against problem P1 (see
    report for further details), when `P1` is false we model against problem P2.
    If `binary` is true we consider boolean variables, if `binary` is false we consider
    free variables.

    # Arguments
    - `instanceMILP`: the MILP instance.
    - **optional** `binary`: true if modeling with binary variables (free variables otherwise).
    - **optional** `solver`: the solver Optimizer function.
"""
function modelMILP(instanceMILP, binary::Bool = true, solver = Gurobi.Optimizer)
    # Création du model
    m = direct_model((solver)())
    set_optimizer_attribute(m, "LogToConsole", 0)
    set_optimizer_attribute(m, "TimeLimit", 50)
    set_optimizer_attribute(m, "LogFile", "gurobi.log")

    X = instanceMILP.X
    Lmax = instanceMILP.Lmax
    Lmin = instanceMILP.Lmin
    B = instanceMILP.B
    R = instanceMILP.R
    V = instanceMILP.V
    O = instanceMILP.O
    Oj = instanceMILP.Oj
    U = instanceMILP.U

    copyB = []
    for r in 1:R
        Brem = deepcopy(B[r])
        pop!(Brem)
        push!(copyB,Brem)
    end

    # Définition des variables
    @variable(m, 0 <= X[r=1:R, j=1:length(B[r]), Oj[r][j].debut:Oj[r][j].fin] <= 1, binary=binary)
    @variable(m, 0 <= Lmax)
    @variable(m, 0 <= Lmin)

    # Définition de l'objectif (la différence entre charges de mail batch à minimiser)
    @objective(m, Min, Lmax - Lmin)

    # Définition des contraintes
    @constraint(m, c2[r=1:R,j in B[r]], sum(X[r, j, k] for k in Oj[r][j].debut:Oj[r][j].fin) == 1 )
    @constraint(m, c3[r=1:R,k=1:O], sum(X[r, j, k] for j in U[r][k]) <= 1 )
    @constraint(m, c4[r=1:R,j in copyB[r]], sum(k * X[r, j, k] for k in Oj[r][j].debut:Oj[r][j].fin) <= sum(k * X[r, j+1, k] for k in Oj[r][j+1].debut:Oj[r][j+1].fin))
    @constraint(m, c5_1[k=1:O], Lmin <= sum(sum(V[r].batch[j] * X[r, j, k] for j in U[r][k]) for r in 1:R))
    @constraint(m, c5_2[k=1:O], sum(sum(V[r].batch[j] * X[r, j, k] for j in U[r][k]) for r in 1:R) <= Lmax)

    write_to_file(m, "model.lp")
    return m
end

function solveMILP(filemodelMILP) 
    lp = read_from_file(filemodelMILP)
    set_optimizer(lp,Gurobi.Optimizer)
    optimize!(lp)
    println(solution_summary(m))
    return nothing
end