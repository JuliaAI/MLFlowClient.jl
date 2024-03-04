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
MLFlowRunDataParam
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
deleteexperiment
searchexperiments
restoreexperiment
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
logbatch
logartifact
listartifacts
```

# Utilities

```@docs
mlfget
mlfpost
uri
generatefilterfromentity_type
generatefilterfromparams
generatefilterfromattributes
healthcheck
```
