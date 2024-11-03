@testset "createexperiment" begin
    @ensuremlf
    exp = createexperiment(mlf)

    @test isa(exp, MLFlowExperiment)
    @test_throws ErrorException createexperiment(mlf; name=exp.name)

    deleteexperiment(mlf, exp)
end

@testset verbose = true "getexperiment" begin
    @ensuremlf
    exp = createexperiment(mlf)
    experiment = getexperiment(mlf, exp.experiment_id)

    @testset "getexperiment_by_experiment_id" begin
        @test isa(experiment, MLFlowExperiment)
        @test experiment.experiment_id == exp.experiment_id
    end

    @testset "getexperiment_by_experiment_name" begin
        experiment_by_name = getexperiment(mlf, exp.name)
        @test isa(experiment_by_name, MLFlowExperiment)
        @test experiment_by_name.experiment_id == exp.experiment_id
    end

    @testset "getexperiment_not_found" begin
        @test isa(getexperiment(mlf, 123), Missing)
    end
    deleteexperiment(mlf, exp)
end

@testset "getorcreateexperiment" begin
    @ensuremlf
    expname = "getorcreate"
    artifact_location = "test$(expname)"
    e = getorcreateexperiment(mlf, expname; artifact_location=artifact_location)
    @test isa(e, MLFlowExperiment)

    ee = getorcreateexperiment(mlf, expname)
    @test isa(ee, MLFlowExperiment)
    @test e === ee
    @test occursin(artifact_location, e.artifact_location)
    deleteexperiment(mlf, ee)
end

@testset "deleteexperiment" begin
    @ensuremlf
    exp = createexperiment(mlf)
    experiments_before = searchexperiments(mlf)
    deleteexperiment(mlf, exp)

    experiments_after = searchexperiments(mlf)
    @test length(experiments_after) == length(experiments_before) - 1 # 1 for the default experiment
end

@testset "restoreexperiment" begin
    @ensuremlf
    exp = createexperiment(mlf)
    experiments_before = searchexperiments(mlf)
    deleteexperiment(mlf, exp)

    experiments_after = searchexperiments(mlf)
    @test length(experiments_after) == length(experiments_before) - 1 # 1 for the default experiment

    restoreexperiment(mlf, exp)
    experiments_after_2 = searchexperiments(mlf)
    @test length(experiments_after_2) == length(experiments_after) + 1 # the restored experiment and the default one

    deleteexperiment(mlf, exp)
end

@testset verbose = true "searchexperiments" begin
    @ensuremlf
    n_experiments_before = length(searchexperiments(mlf))
    for i in 1:2
        createexperiment(mlf)
    end
    createexperiment(mlf; name="test")
    experiments = searchexperiments(mlf)

    @testset "searchexperiments_get_all" begin
        @test length(experiments) == (n_experiments_before + 3) # Adding one for the default experiment
    end

    @testset "searchexperiments_by_filter" begin
        experiments_by_filter = searchexperiments(mlf; filter="name=\"test\"")
        @test length(experiments_by_filter) == 1
        @test experiments_by_filter[1].name == "test"
    end

    @testset "searchexperiments_by_filter_attributes" begin
        experiments_by_filter = searchexperiments(mlf; filter_attributes=Dict("name" => "test"))
        @test length(experiments_by_filter) == 1
        @test experiments_by_filter[1].name == "test"
    end

    @testset "searchexperiments_filter_exception" begin
        @test_throws ErrorException searchexperiments(mlf; filter="test", filter_attributes=Dict("test" => "test"))
    end

    popfirst!(experiments) # removing the default experiment (it can't be deleted)
    for e in experiments
        deleteexperiment(mlf, e)
    end
end
