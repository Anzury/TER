using PyPlot

# plot the evolution of solutions found (values of f(s)) during the algorithm
function plotsolutions(solutions,sol, target, fonctionobjectif, pourcentage, decroissance, nbiterstagnant, nbiterameliore)
    figure("evolution of solutions for $target")
    title(string("f(s) for ", fonctionobjectif, " ", pourcentage, " ", decroissance, " ", nbiterstagnant))
    plot(solutions, label="nbiterameliore= $nbiterameliore")
    legend(loc=1, fontsize ="small")
end
