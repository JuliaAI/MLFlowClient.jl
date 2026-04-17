@testset verbose = true "artifact types" begin
    @testset "FileInfo direct constructor" begin
        fi = FileInfo("path/to/file.txt", false, 1024)
        @test fi.path == "path/to/file.txt"
        @test fi.is_dir == false
        @test fi.file_size == 1024
    end

    @testset "FileInfo directory" begin
        fi = FileInfo("path/to/dir", true, 0)
        @test fi.is_dir == true
        @test fi.file_size == 0
    end

    @testset "FileInfo show" begin
        fi = FileInfo("test.txt", false, 100)
        io = IOBuffer()
        show(io, fi)
        @test !isempty(String(take!(io)))
    end

    @testset "MultipartUploadCredential direct constructor" begin
        cred = MultipartUploadCredential(1, "https://s3.example.com/upload", Dict("x-amz-key" => "value"))
        @test cred.part_number == 1
        @test cred.upload_url == "https://s3.example.com/upload"
        @test cred.headers["x-amz-key"] == "value"
    end

    @testset "MultipartUploadPart direct constructor" begin
        part = MultipartUploadPart(1, "etag-abc123")
        @test part.part_number == 1
        @test part.etag == "etag-abc123"
    end
end
