module Releases

using Dates: Date, DateTime
using HTTP
using JSON

using ..APIKey
using ..Responses: SeriesResponse, TagsResponse

struct Release
    id::Int
    realtime_start::Date
    realtime_end::Date
    name::String
    press_release::Bool
    link::Union{Nothing,String}
end

struct ReleasesResponse
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    releases::Vector{Release}
end

function releases(;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if !isnothing(limit)
        push!(query, "limit" => limit)  # TODO: validate
    end
    if !isnothing(offset)
        push!(query, "offset" => offset)  # TODO: validate
    end
    if !isnothing(order_by)
        push!(query, "order_by" => order_by)  # TODO: validate
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => sort_order)  # TODO: validate
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/releases"; query)
    releases_response = JSON.parse(http_response.body, ReleasesResponse)
    return releases_response
end

struct NamedReleaseDate
    release_id::Int
    release_name::String
    date::Date
end

struct ReleaseDatesResponse{T}
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    release_dates::Vector{T}
end

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
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if !isnothing(limit)
        push!(query, "limit" => limit)  # TODO: validate
    end
    if !isnothing(offset)
        push!(query, "offset" => offset)  # TODO: validate
    end
    if !isnothing(order_by)
        push!(query, "order_by" => order_by)  # TODO: validate
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => sort_order)  # TODO: validate
    end
    if !isnothing(include_release_dates_with_no_data)
        push!(query, "include_release_dates_with_no_data" => include_release_dates_with_no_data)
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/releases/dates"; query)
    release_dates_response = JSON.parse(http_response.body, ReleaseDatesResponse{NamedReleaseDate})
    return release_dates_response
end

struct ReleaseResponse
    realtime_start::Date
    realtime_end::Date
    releases::Vector{Release}
end

function release(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release"; query)
    release_response = JSON.parse(http_response.body, ReleaseResponse)
    return only(release_response.releases)
end

struct ReleaseDate
    release_id::Int
    date::Date
end

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
    query = [
        "api_key" => APIKey.get(api_key),
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
        push!(query, "limit" => limit)  # TODO: validate
    end
    if !isnothing(offset)
        push!(query, "offset" => offset)  # TODO: validate
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => sort_order)  # TODO: validate
    end
    if !isnothing(include_release_dates_with_no_data)
        push!(query, "include_release_dates_with_no_data" => include_release_dates_with_no_data)
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release/dates"; query)
    release_dates_response = JSON.parse(http_response.body, ReleaseDatesResponse{ReleaseDate})
    return release_dates_response
end

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
    query = [
        "api_key" => APIKey.get(api_key),
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
        push!(query, "limit" => limit)  # TODO: validate
    end
    if !isnothing(offset)
        push!(query, "offset" => offset)  # TODO: validate
    end
    if !isnothing(order_by)
        push!(query, "order_by" => order_by)  # TODO: validate
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => sort_order)  # TODO: validate
    end
    if !isnothing(filter_variable)
        push!(query, "filter_variable" => filter_variable)  # TODO: validate
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))  # TODO: maybe validate
    end
    if length(exclude_tag_names) > 0
        push!(query, "exclude_tag_names" => join(exclude_tag_names, ';'))  # TODO: maybe validate
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release/series"; query)
    series_response = JSON.parse(http_response.body, SeriesResponse)
    return series_response
end

struct Source
    id::Int
    realtime_start::Date
    realtime_end::Date
    name::String
    link::String
end

struct SourcesResponse
    realtime_start::Date
    realtime_end::Date
    sources::Vector{Source}
end

function sources(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release/sources"; query)
    sources_response = JSON.parse(http_response.body, SourcesResponse)
    return sources_response
end


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
    query = [
        "api_key" => APIKey.get(api_key),
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
        push!(query, "tag_group_id" => tag_group_id)  # TODO: validate
    end
    if !isnothing(search_text)
        push!(query, "search_text" => search_text)
    end
    if !isnothing(limit)
        push!(query, "limit" => limit)  # TODO: validate
    end
    if !isnothing(offset)
        push!(query, "offset" => offset)  # TODO: validate
    end
    if !isnothing(order_by)
        push!(query, "order_by" => order_by)  # TODO: validate
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => sort_order)  # TODO: validate
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release/tags"; query)
    tags_response = JSON.parse(http_response.body, TagsResponse)
    return tags_response
end

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
    query = [
        "api_key" => APIKey.get(api_key),
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
        push!(query, "tag_group_id" => tag_group_id)  # TODO: validate
    end
    if !isnothing(search_text)
        push!(query, "search_text" => search_text)
    end
    if !isnothing(limit)
        push!(query, "limit" => limit)  # TODO: validate
    end
    if !isnothing(offset)
        push!(query, "offset" => offset)  # TODO: validate
    end
    if !isnothing(order_by)
        push!(query, "order_by" => order_by)  # TODO: validate
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => sort_order)  # TODO: validate
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release/related_tags"; query)
    tags_response = JSON.parse(http_response.body, TagsResponse)
    return tags_response
end

struct TableElement
    element_id::Int
    release_id::Int
    series_id::Union{Nothing,String}
    parent_id::Union{Nothing,Int}
    line::Union{Nothing,String}  # integer as string?
    type::String
    name::String
    level::String  # integer as string?
    children::Vector{TableElement}
end

struct TableResponse
    name::Union{Nothing,String}
    element_id::Union{Nothing,Int}
    release_id::String  # integer as string?
    elements::Dict{String,TableElement}
end

function tables(
    release_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    element_id::Union{Nothing,Integer}=nothing,
    include_observation_values::Union{Nothing,Bool}=nothing,
    observation_date::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "release_id" => release_id,
    ]
    if !isnothing(element_id)
        push!(query, "element_id" => element_id)
    end
    if !isnothing(include_observation_values)
        push!(query, "include_observation_values" => include_observation_values)
    end
    if !isnothing(observation_date)
        push!(query, "observation_date" => observation_date)
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/release/tables"; query)
    table_response = JSON.parse(http_response.body, TableResponse)
    return table_response

end

# Allow Release objects to be used in place of release_id integers
for op in (:release, :dates, :series, :sources, :tags, :related_tags, :tables)
    @eval $op(r::Release; kwargs...) = $op(r.id; kwargs...)
end

end  # module
