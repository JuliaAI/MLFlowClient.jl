# Reference

```@meta
CurrentModule = MLFlowClient
```

# Types

TODO: Document accessors.

```@docs
MLFlow
MLFlowExperiment
MLFlowRun
MLFlowRunInfo
MLFlowRunData
MLFlowRunDataMetric
MLFlowRunStatus
MLFlowArtifactFileInfo
MLFlowArtifactDirInfo
```

# Experiments

```@docs
createexperiment
getexperiment
getorcreateexperiment
listexperiments
deleteexperiment
```

# Runs

```@docs
createrun
getrun
updaterun
deleterun
searchruns
logparam
logmetric
logartifact
listartifacts
```

# Utilities

```@docs
mlfget
mlfpost
uri
generatefilterfromparams
```
