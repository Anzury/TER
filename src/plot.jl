using PyPlot

# plot the evolution of solutions found (values of f(s)) during the algorithm
function plotsolutions(solutions, target, fonctionobjectif, pourcentage, decroissance, nbiterstagnant, nbiterameliore)
    figure("evolution of solutions for $target")
    plot(solutions,label = string("f(s) for ", fonctionobjectif, " ", pourcentage, " ", decroissance, " ", nbiterstagnant, " ", nbiterameliore))
end