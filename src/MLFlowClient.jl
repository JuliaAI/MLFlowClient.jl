"""
    MLFlowClient

[MLFlowClient](https://github.com/JuliaAI.jl) is a [Julia](https://julialang.org/) package
for working with [MLFlow](https://mlflow.org/) using the REST
[API v2.0](https://www.mlflow.org/docs/latest/rest-api.html).

`MLFlowClient` allows you to create and manage `MLFlow` experiments, runs, and log parameters, metrics,
and artifacts. If you are not familiar with `MLFlow` and its concepts, please refer to
[MLFlow documentation](https://mlflow.org/docs/latest/index.html).
"""
module MLFlowClient

using Dates
using UUIDs
using HTTP
using Base64
using URIs
using JSON
using ShowCases

include("types/mlflow.jl")
export MLFlow

include("types/tag.jl")
export Tag

include("types/enums.jl")
export ViewType, RunStatus, ModelVersionStatus, Permission, DeploymentJobRunState, State,
    WebhookStatus, WebhookEvent, JobState, OptimizerType,
    RoutingStrategy, FallbackStrategy, BudgetUnit, BudgetDurationUnit,
    BudgetTargetScope, BudgetAction, GatewayModelLinkageType,
    GuardrailStage, GuardrailAction,
    LabelSchemaType, ReviewItemType, ReviewQueueType, ReviewStatus

include("types/dataset.jl")
export Dataset, DatasetInput

include("types/artifact.jl")
export FileInfo, MultipartUploadCredential, MultipartUploadPart

include("types/model.jl")
export ModelInput, ModelMetric, ModelOutput, ModelParam, ModelVersion,
    ModelVersionDeploymentJobState

include("types/registered_model.jl")
export RegisteredModel, RegisteredModelAlias

include("types/experiment.jl")
export Experiment

include("types/run.jl")
export Run, Param, Metric, RunData, RunInfo, RunInputs, RunOutputs

include("types/user.jl")
export User

include("types/role.jl")
export Role, RolePermission, UserRoleAssignment, UserPermission

include("types/workspace.jl")
export Workspace, TraceArchivalConfig

include("types/webhook.jl")
export Webhook, WebhookTestResult, WebhookEntity, WebhookAction, WebhookEvent

include("types/scorer.jl")
export Scorer

include("types/gateway.jl")
export GatewaySecretInfo, GatewayModelDefinition, GatewayEndpoint, GatewayEndpointConfig,
    GatewayEndpointBinding, GatewayBudgetWindow,
    FallbackConfig, BudgetDuration, GatewayEndpointModelConfig,
    GatewayEndpointModelMapping, GatewayEndpointTag, GatewayBudgetPolicy,
    GatewayGuardrail, GatewayGuardrailConfig

include("types/prompt_optimization.jl")
export PromptOptimizationJob, PromptOptimizationJobConfig, PromptOptimizationJobTag,
    InitialEvalScoresEntry, FinalEvalScoresEntry, JobStateInfo

include("types/label_schema.jl")
export LabelSchema, LabelSchemaInput, InputPassFail, InputCategorical, InputNumeric,
    InputText

include("types/review_queue.jl")
export ReviewQueue, ReviewQueueItem

include("api.jl")

include("utils.jl")

include("services/experiment.jl")
export getexperiment, createexperiment, deleteexperiment, setexperimenttag,
    deleteexperimenttag,
    updateexperiment, restoreexperiment, searchexperiments, getexperimentbyname

include("services/run.jl")
export getrun, createrun, deleterun, setruntag, updaterun, restorerun, searchruns,
    deleteruntag

include("services/logger.jl")
export logbatch, loginputs, logmetric, logmodel, logparam

include("services/artifact.jl")
export listartifacts, downloadartifact, uploadartifact, listartifactsdirect,
    deleteartifact, createmultipartupload, completemultipartupload,
    abortmultipartupload, getpresigneddownloadurl, createpresigneduploadurl

include("services/misc.jl")
export refresh, getmetrichistory

include("services/registered_model.jl")
export getregisteredmodel, createregisteredmodel, deleteregisteredmodel,
    renameregisteredmodel, updateregisteredmodel, searchregisteredmodels,
    setregisteredmodeltag, deleteregisteredmodeltag, deleteregisteredmodelalias,
    setregisteredmodelalias

include("services/model_version.jl")
export getlatestmodelversions, getmodelversion, createmodelversion, deletemodelversion,
    updatemodelversion, searchmodelversions, getdownloaduriformodelversionartifacts,
    transitionmodelversionstage, setmodelversiontag, deletemodelversiontag,
    getmodelversionbyalias, listmodelversionartifacts

include("services/user.jl")
export createuser, getuser, updateuserpassword, updateuseradmin, deleteuser, listusers,
    getcurrentuser,
    createrole, getrole, listroles, updaterole, deleterole,
    addrolepermission, removerolepermission, listrolepermissions, updaterolepermission,
    assignrole, unassignrole, listuserroles, listroleusers,
    grantuserpermission, revokeuserpermission, getuserpermission, listuserpermissions,
    listcurrentuserpermissions

include("services/workspace.jl")
export listworkspaces, createworkspace, getworkspace, updateworkspace, deleteworkspace

include("services/webhook.jl")
export createwebhook, getwebhook, listwebhooks, updatewebhook, deletewebhook, testwebhook

include("services/scorer.jl")
export registerscorer, listscorers, listscorerversions, getscorer, deletescorer

include("services/gateway.jl")
export creategatewaysecret, getgatewaysecretinfo, updategatewaysecret, deletegatewaysecret,
    listgatewaysecretinfos,
    creategatewaymodeldefinition, getgatewaymodeldefinition, listgatewaymodeldefinitions,
    updategatewaymodeldefinition, deletegatewaymodeldefinition,
    creategatewayendpoint, getgatewayendpoint, updategatewayendpoint, deletegatewayendpoint,
    listgatewayendpoints,
    attachmodeltogatewayendpoint, detachmodelfromgatewayendpoint,
    creategatewayendpointbinding, deletegatewayendpointbinding, listgatewayendpointbindings,
    setgatewayendpointtag, deletegatewayendpointtag,
    creategatewaybudget, getgatewaybudget, updategatewaybudget, deletegatewaybudget,
    listgatewaybudgets, listgatewaybudgetwindows,
    creategatewayguardrail, getgatewayguardrail, deletegatewayguardrail,
    listgatewayguardrails, addguardrailtoendpoint, removeguardrailfromendpoint,
    listendpointguardrailconfigs, updateendpointguardrailconfig

include("services/prompt_optimization.jl")
export createpromptoptimizationjob, getpromptoptimizationjob, searchpromptoptimizationjobs,
    cancelpromptoptimizationjob, deletepromptoptimizationjob

include("services/label_schema.jl")
export createlabelschema, getlabelschema, getlabelschemabyname, listlabelschemas,
    updatelabelschema, deletelabelschema

include("services/review_queue.jl")
export createreviewqueue, getorcreateuserqueue, getreviewqueue, getreviewqueuebyname,
    listreviewqueues, updatereviewqueue, deletereviewqueue, additemstoreviewqueue,
    removeitemsfromreviewqueue, listreviewqueueitems, setreviewqueueitemstatus

end
