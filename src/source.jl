module source

using Compat
using Dates: Date
using HTTP
using JSON

using ..FredData: get_api_key
using ..Responses: ReleasesResponse, SimpleSourcesResponse, Source, SourcesResponse
using ..Validation

@compat public get, get_all, releases

"""
    get_all(; <keyword arguments>)

Get all data sources

See [`fred/sources`](https://fred.stlouisfed.org/docs/api/fred/sources.html).
"""
function get_all(;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if !isnothing(limit)
        push!(query, "limit" => validate_limit(limit))
    end
    if !isnothing(offset)
        push!(query, "offset" => validate_offset(offset))
    end
    if !isnothing(order_by)
        order_by in (
            "source_id",
            "name",
            "realtime_start",
            "realtime_end",
        ) || throw(ArgumentError("invalid order_by $order_by"))
        push!(query, "order_by" => String(order_by))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/sources"; query)
    return JSON.parse(http_response.body, SourcesResponse)
end

"""
    get(source_id; <keyword arguments>)

Get a data source

See [`fred/source`](https://fred.stlouisfed.org/docs/api/fred/source.html).
"""
function get(
    source_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "source_id" => source_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/source"; query)
    return JSON.parse(http_response.body, SimpleSourcesResponse)
end

"""
    releases(source_id; <keyword arguments>)

Get the releases for the `source_id` source

See [`fred/source/releases`](https://fred.stlouisfed.org/docs/api/fred/source_releases.html).
"""
function releases(
    source_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "source_id" => source_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if !isnothing(limit)
        push!(query, "limit" => validate_limit(limit))
    end
    if !isnothing(offset)
        push!(query, "offset" => validate_offset(offset))
    end
    if !isnothing(order_by)
        order_by in (
            "release_id",
            "name",
            "press_release",
            "realtime_start",
            "realtime_end",
        ) || throw(ArgumentError("invalid order_by $order_by"))
        push!(query, "order_by" => String(order_by))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/source/releases"; query)
    return JSON.parse(http_response.body, ReleasesResponse)
end

# Allow Source objects to be used in place of source_id integers
for op in (:get, :releases)
    @eval $op(s::Source, args...; kwargs...) = $op(s.id, args...; kwargs...)
end


end  # module
