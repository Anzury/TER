using JuMP

"""
    modelMILP(solver, instance[, P1, binary])

    Create the MILP model corresponding to _instance_ using
    `solver` as the optimizer. When `P1` is true we model against problem P1 (see
    report for further details), when `P1` is false we model against problem P2.
    If `binary` is true we consider boolean variables, if `binary` is false we consider
    free variables.

    # Arguments
    - `instance`: the MILP instance.
    - **optional** `binary`: true if modeling with binary variables (free variables otherwise).
    - **optional** `solver`: the solver Optimizer function.
"""
function modelMILP(instance, binary::Bool = true, solver = Gurobi.Optimizer)
    # Création du model
    m = direct_model((solver)())
    set_optimizer_attribute(m, "LogToConsole", 0)

    X = instance.X
    Lmax = instance.Lmax
    Lmin = instance.Lmin
    B = instance.B
    R = instance.R
    V = instance.V 
    O = instance.O 
    Oj = instance.Oj 
    U = instance.U 

    # Définition des variables
    @variable(m, 0 <= X <= 1, binary=binary)
    @variable(m, 0 <= Lmax)
    @variable(m, 0 <= Lmin)

    # Définition de l'objectif (la somme des yj à minimiser)
    @objective(m, Min, Lmax - Lmin)

    list = []
    for r in 1:R 
        batch = B[r]
        for j in batch
            push!(list,(j,r))
        end
    end

    list2 = []
    for k in 1:O
        for r in 1:R
            push!(list2,(k,r))
        end
    end

    list3 = []
    for r in 1:R
        Brem = deepcopy(B[r])
        pop!(Brem)
        for j in Brem
            push!(list3,(j,r))
        end
    end

    allj = [i for (i,j) in list]
    allr = [j for (i,j) in list]

    # Définition des contraintes
    # @constraint(m, c2[[(j,r) for (j,r) in list]], sum(X[r][j][k] for k in Oj[r][j].debut:Oj[r][j].fin) == 1 ) # 2
    for (j,r) in list
        @constraint(m, c2, sum(X[r][j][k] for k=Oj[r][j].debut:Oj[r][j].fin) == 1 ) # 2
    end
    # @constraint(m, c3[[(k,r) for (k,r) in list2]], sum(X[r][j][k] for j in U[r][k]) <= 1 ) # 3
    for (k,r) in list2
        @constraint(m, c3, sum(X[r][j][k] for j in U[r][k]) <= 1 ) # 3
    end
    # @constraint(m, c4[[(j,r) for (j,r) in list3]], sum(k * X[r][j][k] for k in Oj[r][j].debut:Oj[r][j].fin) <= sum(k * X[r][j+1][k] for k in Oj[r][j+1].debut:Oj[r][j+1].fin)) # 4
    for (j,r) in list3
    @constraint(m, c4, sum(k * X[r][j][k] for k in Oj[r][j].debut:Oj[r][j].fin) <= sum(k * X[r][j+1][k] for k in Oj[r][j+1].debut:Oj[r][j+1].fin)) # 4
    end
    @constraint(m, c5[k=1:O], Lmin <= sum(sum(V[r].batch[j] * X[r][j][k] for j in U[r][k]) for r in 1:R) <= Lmax) # 5

    return m
end
