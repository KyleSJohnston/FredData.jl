module FredData

using Compat
using DataFrames
using Dates
using HTTP: HTTP
using JSON: JSON
using Logging
using Printf
using TimeZones

export
       # Fred object
       Fred, get_api_url, set_api_url!,

       # FredSeries object
       FredSeries,

       # Download data
       get_data

@compat public get_api_key, set_api_key

const MAX_ATTEMPTS       = 3
const FIRST_REALTIME     = Date(1776,07,04)
const LAST_REALTIME      = Date(9999,12,31)
const EARLY_VINTAGE_DATE = "1991-01-01"
const FRED_DATE_FORMAT   = DateFormat("yyyy-mm-dd HH:MM:SSzz")
const OUTPUT_TZ_TYPE     = UTC
const API_URL            = "https://api.stlouisfed.org/fred/"
const API_KEY_LENGTH     = 32
const KEY_ENV_NAME       = "FRED_API_KEY"
const KEY_FILE_NAME      = ".freddatarc"
const API_KEY            = Ref{Union{Nothing,String}}(nothing)

# From https://fred.stlouisfed.org/docs/api/fred/category_series.html#Parameters
function validate_api_key(api_key::AbstractString)
    length(api_key) == API_KEY_LENGTH && all(isxdigit, api_key) || throw(ArgumentError("Invalid FRED API key $api_key"))
    return String(api_key)
end

"""
    set_api_key(api_key)

Sets the global api-key constant to `api_key`
"""
function set_api_key(api_key::AbstractString)
    API_KEY[] = validate_api_key(api_key)
    return nothing  # otherwise this looks a lot like `get_api_key`...
end
function set_api_key(::Nothing)
    API_KEY[] = nothing  # Bypass validation to un-set the key
    return nothing
end

"""
    get_api_key(api_key)

Obtains an `api_key` for use in HTTP requests

- If `api_key` is an instance of `AbstractString`, a `String` representation of `api_key` is returned.
- If `api_key` is `nothing`, the global API key is returned. (See `set(api_key)`(@ref))

This method serves as the default approach to obtaining an api_key in many
functions.
"""
get_api_key(api_key::AbstractString)::String = validate_api_key(api_key)
get_api_key(::Nothing) = return API_KEY[]

key_file() = joinpath(homedir(), KEY_FILE_NAME)

function load_fred_key()
    if haskey(ENV, KEY_ENV_NAME)
        @info "Loading FRED API Key from environment"
        set_api_key(ENV[KEY_ENV_NAME])
    elseif isfile(key_file())
        @info "Loading FRED API Key from key file"
        set_api_key(readchomp(key_file()))
    else
        @info "Unable to detect FRED API Key"
        @warn "Run FredData.set_api_key to set a global API key"
    end
end

function __init__()
    load_fred_key()
end

include("validation.jl")

# Fred connection type
"""
A connection to the Fred API.

Constructors
------------
- `Fred()`: Key detected automatically. First, looks for the environment variable
    `FRED_API_KEY`, then looks for the file `~/.freddatarc`.
- `Fred(key::AbstractString)`: User specifies key directly

Arguments
---------
- `key`: Registration key provided by FRED.

Notes
-----
- Set the API url with `set_api_url!(f::Fred, url::AbstractString)`
"""
struct Fred end

"""Get the FRED API key that is used for this connection"""
function get_api_key(::Fred)
    key = get_api_key(nothing)  # source global key
    !isnothing(key) || error("FRED API not set; run FredData.set_api_key")
    return key
end

"""Get the base URL used to connect to the FRED server"""
get_api_url(::Fred) = API_URL

"""Set the base URL used to connect to the FRED server"""
set_api_url!(f::Fred, url::AbstractString) = setfield!(f, :url, url)

function Base.show(io::IO, f::Fred)
    @printf io "FRED API Connection\n"
    @printf io "\turl: %s\n" get_api_url(f)
    @printf io "\tkey: %s\n" get_api_key(f)
end


"""
```
FredSeries(...)
```

Represent a single data series, and all associated metadata, as queried from FRED.

The following fields are available:
- `id`: Series ID
- `title`: Series title
- `units_short`: Units (abbr.)
- `units`: Units
- `seas_adj_short`: Seasonal adjustment (abbr.)
- `seas_adj`:Seasonal adjustment
- `freq_short`:*Native* frequency (abbr.)
- `freq`:*Native* frequency
- `realtime_start`:Date realtime period starts
- `realtime_end`:Date realtime period ends
- `last_updated`:Date series last updated
- `notes`:Series notes
- `trans_short`:Transformation of queried data (abbr.)
- `data`:The actual data; DataFrame with columns `:realtime_start`,
  `:realtime_end`, `:date`, `:value`

"""
struct FredSeries
    # From series query
    id::AbstractString
    title::AbstractString
    units_short::AbstractString
    units::AbstractString
    seas_adj_short::AbstractString
    seas_adj::AbstractString
    freq_short::AbstractString
    freq::AbstractString
    realtime_start::AbstractString
    realtime_end::AbstractString
    last_updated::DateTime
    notes::AbstractString

    # From series/observations query
    trans_short::AbstractString # "units"
    data::DataFrames.DataFrame

    # deprecated
    df::DataFrames.DataFrame
end

function Base.show(io::IO, s::FredSeries)
    @printf io "FredSeries\n"
    @printf io "\tid: %s\n"                s.id
    @printf io "\ttitle: %s\n"             s.title
    @printf io "\tunits: %s\n"             s.units
    @printf io "\tseas_adj (native): %s\n" s.seas_adj
    @printf io "\tfreq (native): %s\n"     s.freq
    @printf io "\trealtime_start: %s\n"    s.realtime_start
    @printf io "\trealtime_end: %s\n"      s.realtime_end
    @printf io "\tlast_updated: %s\n"      s.last_updated
    @printf io "\tnotes: %s\n"             s.notes
    @printf io "\ttrans_short: %s\n"       s.trans_short
    @printf io "\tdata: %dx%d DataFrame with columns %s\n" size(s.data)... names(s.data)
end

# old, deprecated accessors
export
    id, title, units_short, units, seas_adj_short, seas_adj, freq_short,
    freq, realtime_start, realtime_end, last_updated, notes, trans_short,
    df
@deprecate id(f::FredSeries) getfield(f, :id)
@deprecate title(f::FredSeries) getfield(f, :title)
@deprecate units_short(f::FredSeries) getfield(f, :units_short)
@deprecate units(f::FredSeries) getfield(f, :units)
@deprecate seas_adj_short(f::FredSeries) getfield(f, :seas_adj_short)
@deprecate seas_adj(f::FredSeries) getfield(f, :seas_adj)
@deprecate freq_short(f::FredSeries) getfield(f, :freq_short)
@deprecate freq(f::FredSeries) getfield(f, :freq)
@deprecate realtime_start(f::FredSeries) getfield(f, :realtime_start)
@deprecate realtime_end(f::FredSeries) getfield(f, :realtime_end)
@deprecate last_updated(f::FredSeries) getfield(f, :last_updated)
@deprecate notes(f::FredSeries) getfield(f, :notes)
@deprecate trans_short(f::FredSeries) getfield(f, :trans_short)
@deprecate df(f::FredSeries) getfield(f, :data)

include("get_data.jl")

end # module
