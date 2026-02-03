module APIKey

using Logging
using ..FredData: API_KEY_LENGTH, KEY_ENV_NAME, key_file

public get, set

const API_KEY = Ref{String}("abcdefghijklmnopqrstuvwxyz123456")  # documentation default

function __init__()
    if haskey(ENV, KEY_ENV_NAME)
        @info "Setting Fred api_key from $KEY_ENV_NAME"
        API_KEY[] = ENV[KEY_ENV_NAME]
    elseif isfile(key_file())
        @info "Setting Fred api_key from $(key_file())"
        API_KEY[] = readchomp(key_file())
    else
        @warn "Unable to automatically detect Fred api_key"
    end
end

function validate(api_key::AbstractString)
    if length(api_key) == API_KEY_LENGTH && all(isxdigit, api_key)
        return String(api_key)
    end
    throw(ArgumentError("invalid api_key: $api_key"))
end

function set(api_key::AbstractString)
    API_KEY[] = validate(api_key)
    return nothing
end

function get(::Nothing)
    return API_KEY[]
end

function get(api_key::AbstractString)
    return validate(api_key)
end

end  # module
