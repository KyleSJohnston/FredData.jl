using FredData
using Test

"Sets global API key to `key`, runs `f()`, and restores the original key"
function with_key(f::Function, key::Union{Nothing,AbstractString})
    prior_key = FredData.get_api_key(nothing)
    FredData.set_api_key(key)
    try
        f()
    finally
        FredData.set_api_key(prior_key)
    end
end

function with_key_env(f::Function, key::AbstractString)
    withenv(FredData.KEY_ENV_NAME => key) do
        f()
    end
end

function with_key_file(f::Function, key::AbstractString)
    mktempdir() do tmpdir
        open(joinpath(tmpdir, FredData.KEY_FILE_NAME), "w") do f
            write(f, key)
        end
        withenv(FredData.KEY_ENV_NAME => nothing,
                "USERPROFILE" => tmpdir,
                "HOME" => tmpdir, ) do
            f()
        end
    end
end

function with_key_none(f::Function)
    mktempdir() do tmpdir
        withenv(FredData.KEY_ENV_NAME => nothing,
                "USERPROFILE" => tmpdir,
                "HOME" => tmpdir, ) do
            f()
        end
    end
end

with_key(nothing) do
    @testset "Client creation with key" begin
        fake_key = repeat("0", FredData.API_KEY_LENGTH)
        fake_key1 = repeat("1", FredData.API_KEY_LENGTH)

        # pass key directly
        FredData.set_api_key(fake_key)
        f1 = FredData.get_api_key(nothing)
        @test f1 == fake_key
        @test FredData.get_api_key(Fred()) == fake_key

        # detect from ENV
        f2 = with_key_env(fake_key1) do
            FredData.load_fred_key()
            return FredData.get_api_key(nothing)
        end
        @test f2 == fake_key1

        # detect from ~/.freddatarc
        # from libuv::uv_os_homedir, we find we need to set USERPROFILE for windows
        # and HOME for *nix
        f3 = with_key_file(fake_key) do
            FredData.load_fred_key()
            return FredData.get_api_key(nothing)
        end
        @test f3 == fake_key
    end

    @testset "Key Validation" begin
        @test_throws ArgumentError FredData.set_api_key("bad key short")

        FredData.set_api_key(nothing)
        @test_throws ErrorException FredData.get_api_key(Fred())
    end
end
