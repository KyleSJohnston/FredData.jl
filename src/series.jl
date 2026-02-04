module series

using Dates: Date, DateTime
using HTTP
using JSON
using StructUtils

using ..APIKey
using ..FredData: FRED_DATE_FORMAT
using ..Responses: CategoryResponse, ObservationsResponse, ReleaseResponse,
    SeriesResponse, SingleSeriesResponse, TagsResponse

# TODO: public declarations


function get(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "series_id" => series_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series"; query)
    return JSON.parse(http_response.body, SingleSeriesResponse)
end

function categories(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "series_id" => series_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series/categories"; query)
    return JSON.parse(http_response.body, CategoryResponse)
end

@enum OutputType begin
    REAL_TIME=1
    VINTAGE_ALL=2
    VINTAGE_NEW_REVISED=3
    INITIAL=4
end

function observations(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
    observation_start::Union{Nothing,Date}=nothing,
    observation_end::Union{Nothing,Date}=nothing,
    units::Union{Nothing,String}=nothing,
    frequency::Union{Nothing,String}=nothing,
    aggregation_method::Union{Nothing,String}=nothing,
    output_type::Union{Nothing,OutputType}=nothing,
    vintage_dates::Vector{Date}=Date[],
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "series_id" => string(series_id),
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
    if !isnothing(observation_start)
        push!(query, "observation_start" => string(observation_start))
    end
    if !isnothing(observation_end)
        push!(query, "observation_end" => string(observation_end))
    end
    if !isnothing(units)
        push!(query, "units" => units)
    end
    if !isnothing(frequency)
        push!(query, "frequency" => frequency)
    end
    if !isnothing(aggregation_method)
        push!(query, "aggregation_method" => aggregation_method)
    end
    if !isnothing(output_type)
        push!(query, "output_type" => Int(output_type))
    end
    if length(vintage_dates) > 0
        push!(query, "vintage_dates" => join(vintage_dates, ','))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series/observations"; query)
    return JSON.parse(http_response.body, ObservationsResponse)
end

function release(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "series_id" => string(series_id),
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series/release"; query)
    return JSON.parse(http_response.body, ReleaseResponse)
end

function search(
    search_text::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    search_type::Union{Nothing,AbstractString}=nothing,
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
        "search_text" => search_text,
    ]
    if !isnothing(search_type)
        push!(query, "search_type" => string(search_type))  # TODO: validate
    end
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
    if !isnothing(filter_value)
        push!(query, "filter_value" => filter_value)
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))  # TODO: maybe validate
    end
    if length(exclude_tag_names) > 0
        push!(query, "exclude_tag_names" => join(exclude_tag_names, ';'))  # TODO: maybe validate
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series/search"; query)
    return JSON.parse(http_response.body, SeriesResponse)
end

function search_tags(
    series_search_text::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    tag_names::AbstractVector{<:AbstractString}=String[],
    tag_group_id::Union{Nothing,AbstractString}=nothing,
    tag_search_text::Union{Nothing,AbstractString}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)   
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "series_search_text" => series_search_text,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))
    end
    if !isnothing(tag_group_id)
        push!(query, "tag_group_id" => tag_group_id)
    end
    if !isnothing(tag_search_text)
        push!(query, "tag_search_text" => tag_search_text)
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series/search/tags"; query)
    return JSON.parse(http_response.body, TagsResponse)
end

function search_related_tags(
    series_search_text::AbstractString,
    tag_names::AbstractVector{<:AbstractString}=String[];
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    exclude_tag_names::AbstractVector{<:AbstractString}=String[],
    tag_group_id::Union{Nothing,AbstractString}=nothing,
    tag_search_text::Union{Nothing,AbstractString}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)   
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "series_search_text" => series_search_text,
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
        push!(query, "tag_group_id" => tag_group_id)
    end
    if !isnothing(tag_search_text)
        push!(query, "tag_search_text" => tag_search_text)
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/series/search/related_tags"; query)
    return JSON.parse(http_response.body, TagsResponse)
end

end  # module
