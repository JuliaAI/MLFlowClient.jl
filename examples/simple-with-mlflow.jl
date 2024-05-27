using Plots
using MLFlowClient
using Random

# Parameters
αs = [0.0, 0.9, 0.98]
n = 100

"""Method that generates price paths of length `n` based on `α`"""
function getpricepath(α, n)
    x = zeros(n + 1)
    x[1] = 0.0
    for t in 1:n
        x[t+1] = α * x[t] + rand()
    end
    x
end
p = plot()

# Create MLFlow instance
mlf = MLFlow("http://localhost:5000/api")

# Initiate new experiment
experiment_id = createexperiment(mlf; name="price-paths")

# Create a run in the new experiment
exprun = createrun(mlf, experiment_id)

# Log parameters and their values
for (idx, α) in enumerate(αs)
    logparam(mlf, exprun, "alpha$(idx)", string(α)) # MLFlow only supports string parameter values
end

# Obtain pricepaths
pricepaths = [getpricepath(α, n) for α in αs]

# Log pricepaths in MLFlow
for (idx, pricepath) in enumerate(pricepaths)
    plot!(p,
        pricepath,
        title="Random price paths",
        label="alpha = $(αs[idx])",
        xlabel="Timestep",
        ylabel="Price"
    )

    logmetric(mlf, exprun, "pricepath$(idx)", pricepath)
end

# Save the price path plot as an image
plotfilename = "pricepaths-plot.png"
png(plotfilename)

# Upload the plot as an artifact associated with the MLFlow experiment's run
logartifact(mlf, exprun, plotfilename)

# remote temporary plot which was already uploaded in MLFlow
rm(plotfilename)

# complete the experiment
updaterun(mlf, exprun, "FINISHED")
