using Plots
using Random

αs = [0.0, 0.9, 0.98]
n = 100
p = plot()

function getpricepath(α, n)
    x = zeros(n + 1)
    x[1] = 0.0
    for t in 1:n
        x[t+1] = α * x[t] + rand()
    end
    x
end

pricepaths = [getpricepath(α, n) for α in αs]

for (idx, pricepath) in enumerate(pricepaths)
    plot!(p, pricepath, title="Random price paths", label="alpha = $(αs[idx])", xlabel="Timestep", ylabel="Price")
end

p
