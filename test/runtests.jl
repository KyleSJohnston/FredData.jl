using FredData
using Test

include("test_without_key.jl")

has_fred_key() = haskey(ENV, FredData.KEY_ENV_NAME) || isfile(FredData.key_file())

# Normal usage - API key must be present in ENV
if has_fred_key()
    include("test_with_key.jl")
end
