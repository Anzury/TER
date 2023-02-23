using PyPlot

# plot the evolution of solutions found (values of f(s)) during the algorithm
function plotsolutions(solutions, title)
    figure("evolution of solutions")
    plot(solutions)
end