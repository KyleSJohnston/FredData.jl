module releases

using Compat
using Dates: Date, DateTime
using HTTP
using JSON

using ..FredData: API_URL, get_api_key
using ..Responses: ReleasesResponse, NamedReleaseDate, ReleaseDatesResponse
using ..Validation

@compat public get_all, dates

"""
    get_all(; <keyword arguments>)

Get all releases

See [`fred/releases`](https://fred.stlouisfed.org/docs/api/fred/releases.html).
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
    http_response = HTTP.get(joinpath(API_URL, "releases"); query)
    return JSON.parse(http_response.body, ReleasesResponse)
end

"""
    dates(; <keyword arguments>)

Get release dates for all releases

See [`fred/releases/dates`](https://fred.stlouisfed.org/docs/api/fred/releases_dates.html).
"""
function dates(;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
    include_release_dates_with_no_data::Union{Nothing,Bool}=nothing,
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
            "release_date",
            "release_id",
            "release_name",
        ) || throw(ArgumentError("invalid order_by $order_by"))
        push!(query, "order_by" => String(order_by))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    if !isnothing(include_release_dates_with_no_data)
        push!(query, "include_release_dates_with_no_data" => string(include_release_dates_with_no_data))
    end
    http_response = HTTP.get(joinpath(API_URL, "releases", "dates"); query)
    return JSON.parse(http_response.body, ReleaseDatesResponse{NamedReleaseDate})
end

end  # module


module release

using Compat
using Dates: Date, DateTime
using HTTP
using JSON

using ..FredData: API_URL, get_api_key
using ..Responses: Release, NamedReleaseDate, ReleaseDate,
    ReleaseDatesResponse, SimpleReleasesResponse, SeriesResponse,
    SimpleSourcesResponse, TableResponse, TagsResponse
using ..Validation

@compat public get, dates, series, sources, tags, related_tags, tables

"""
    get(release_id; <keyword arguments>)

Gets a data release

See [`fred/release`](https://fred.stlouisfed.org/docs/api/fred/release.html).
"""
function get(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get(joinpath(API_URL, "release"); query)
    return JSON.parse(http_response.body, SimpleReleasesResponse)
end

"""
    dates(release_id; <keyword arguments>)

Gets release dates for a single data release

See [`fred/release/dates`](https://fred.stlouisfed.org/docs/api/fred/release_dates.html).
"""
function dates(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
    include_release_dates_with_no_data::Union{Nothing,Bool}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if !isnothing(limit)
        push!(query, "limit" => validate_limit(limit; ubound=10_000))
    end
    if !isnothing(offset)
        push!(query, "offset" => validate_offset(offset))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    if !isnothing(include_release_dates_with_no_data)
        push!(query, "include_release_dates_with_no_data" => string(include_release_dates_with_no_data))
    end
    http_response = HTTP.get(joinpath(API_URL, "release", "dates"); query)
    return JSON.parse(http_response.body, ReleaseDatesResponse{ReleaseDate})
end

"""
    series(release_id; <keyword arguments>)

Get the series for a data release

See [`fred/release/series`](https://fred.stlouisfed.org/docs/api/fred/release_series.html).
"""
function series(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
    filter_variable::Union{Nothing,AbstractString}=nothing,
    filter_value::Union{Nothing,AbstractString}=nothing,
    tag_names::AbstractVector{<:AbstractString}=String[],
    exclude_tag_names::AbstractVector{<:AbstractString}=String[],
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
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
            "series_id",
            "title",
            "units",
            "frequency",
            "seasonal_adjustment",
            "realtime_start",
            "realtime_end",
            "last_updated",
            "observation_start",
            "observation_end",
            "popularity",
            "group_popularity",
        ) || throw(ArgumentError("invalid order_by $order_by"))
        push!(query, "order_by" => String(order_by))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    if !isnothing(filter_variable)
        push!(query, "filter_variable" => validate_filter_variable(filter_variable))
    end
    if !isnothing(filter_value)
        push!(query, "filter_value" => String(filter_value))
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))  # TODO: maybe validate
    end
    if length(exclude_tag_names) > 0
        push!(query, "exclude_tag_names" => join(exclude_tag_names, ';'))  # TODO: maybe validate
    end
    http_response = HTTP.get(joinpath(API_URL, "release", "series"); query)
    return JSON.parse(http_response.body, SeriesResponse)
end

"""
    sources(release_id; <keyword arguments>)

Get the sources for a data release

See [`fred/release/sources`](https://fred.stlouisfed.org/docs/api/fred/release_sources.html).
"""
function sources(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get(joinpath(API_URL, "release", "sources"); query)
    return JSON.parse(http_response.body, SimpleSourcesResponse)
end

"""
    tags(release_id; <keyword arguments>)

Get the tags for a release

See [`fred/release/tags`](https://fred.stlouisfed.org/docs/api/fred/release_tags.html).
"""
function tags(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    tag_names::AbstractVector{<:AbstractString}=String[],
    tag_group_id::Union{Nothing,AbstractString}=nothing,
    search_text::Union{Nothing,AbstractString}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))  # TODO: maybe validate
    end
    if !isnothing(tag_group_id)
        push!(query, "tag_group_id" => validate_tag_group_id(tag_group_id))
    end
    if !isnothing(search_text)
        push!(query, "search_text" => search_text)
    end
    if !isnothing(limit)
        push!(query, "limit" => validate_limit(limit))
    end
    if !isnothing(offset)
        push!(query, "offset" => validate_offset(offset))
    end
    if !isnothing(order_by)
        order_by in (
            "series_count",
            "popularity",
            "created",
            "name",
            "group_id",
        ) || throw(ArgumentError("invalid order_by $order_by"))
        push!(query, "order_by" => String(order_by))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    http_response = HTTP.get(joinpath(API_URL, "release", "tags"); query)
    return JSON.parse(http_response.body, TagsResponse)
end

"""
    related_tags(release_id, tag_names; <keyword arguments>)

Get related tags for `tag_names` within release `release_id`

See [`fred/release/related_tags`](https://fred.stlouisfed.org/docs/api/fred/release_related_tags.html).
"""
function related_tags(
    release_id::Integer,
    tag_names::AbstractVector{<:AbstractString};
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    exclude_tag_names::AbstractVector{<:AbstractString}=String[],
    tag_group_id::Union{Nothing,AbstractString}=nothing,
    search_text::Union{Nothing,AbstractString}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
        "tag_names" => join(tag_names, ';'),
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if length(exclude_tag_names) > 0
        push!(query, "exclude_tag_names" => join(exclude_tag_names, ';'))  # TODO: maybe validate
    end
    if !isnothing(tag_group_id)
        push!(query, "tag_group_id" => validate_tag_group_id(tag_group_id))
    end
    if !isnothing(search_text)
        push!(query, "search_text" => search_text)
    end
    if !isnothing(limit)
        push!(query, "limit" => validate_limit(limit))
    end
    if !isnothing(offset)
        push!(query, "offset" => validate_offset(offset))
    end
    if !isnothing(order_by)
        order_by in (
            "series_count",
            "popularity",
            "created",
            "name",
            "group_id",
        ) || throw(ArgumentError("invalid order_by $order_by"))
        push!(query, "order_by" => String(order_by))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    http_response = HTTP.get(joinpath(API_URL, "release", "related_tags"); query)
    return JSON.parse(http_response.body, TagsResponse)
end

"""
    tables(release_id; <keyword arguments>)

Get release tables for release `release_id`

See [`fred/release/tables`](https://fred.stlouisfed.org/docs/api/fred/release_tables.html).
"""
function tables(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    element_id::Union{Nothing,Integer}=nothing,
    include_observation_values::Union{Nothing,Bool}=nothing,
    observation_date::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(element_id)
        push!(query, "element_id" => element_id)
    end
    if !isnothing(include_observation_values)
        push!(query, "include_observation_values" => string(include_observation_values))
    end
    if !isnothing(observation_date)
        push!(query, "observation_date" => observation_date)
    end
    http_response = HTTP.get(joinpath(API_URL, "release", "tables"); query)
    return JSON.parse(http_response.body, TableResponse)

end

# Allow Release objects to be used in place of release_id integers
for op in (:get, :dates, :series, :sources, :tags, :related_tags, :tables)
    @eval $op(r::Release, args...; kwargs...) = $op(r.id, args...; kwargs...)
end

end  # module
