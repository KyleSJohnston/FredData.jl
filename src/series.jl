module series

using Compat
using Dates: Date, @dateformat_str, DateTime, format
using HTTP
using JSON

using ..FredData: API_URL, get_api_key
using ..Responses: CategoryResponse, ObservationsResponse, SimpleReleasesResponse,
    Series, SeriesResponse, SimpleSeriesResponse, TagsResponse, VintageDatesResponse
using ..Validation

@compat public get, categories, observations, release, search, search_tags,
    search_related_tags, tags, updates, vintagedates

"""
    get(series_id; <keyword arguments>)

Get a data series

See [`fred/series`](https://fred.stlouisfed.org/docs/api/fred/series.html).
"""
function get(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "series_id" => series_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get(joinpath(API_URL, "series"); query)
    return JSON.parse(http_response.body, SimpleSeriesResponse)
end

"""
    categories(series_id; <keyword arguments>)

Get the categories for series `series_id`

See [`fred/series/categories`](https://fred.stlouisfed.org/docs/api/fred/series_categories.html).
"""
function categories(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "series_id" => series_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get(joinpath(API_URL, "series", "categories"); query)
    return JSON.parse(http_response.body, CategoryResponse)
end

@enum OutputType begin
    REAL_TIME=1
    VINTAGE_ALL=2
    VINTAGE_NEW_REVISED=3
    INITIAL=4
end

"""
    observations(series_id; <keyword arguments>)

Get the observations or data values for a data series

See [`fred/series/observations`](https://fred.stlouisfed.org/docs/api/fred/series_observations.html).
"""
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
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
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
        push!(query, "limit" => validate_limit(limit; ubound=100_000))
    end
    if !isnothing(offset)
        push!(query, "offset" => validate_offset(offset))
    end
    if !isnothing(sort_order)
        push!(query, "sort_order" => validate_sort_order(sort_order))
    end
    if !isnothing(observation_start)
        push!(query, "observation_start" => string(observation_start))
    end
    if !isnothing(observation_end)
        push!(query, "observation_end" => string(observation_end))
    end
    if !isnothing(units)
        push!(query, "units" => validate_units(units))
    end
    if !isnothing(frequency)
        push!(query, "frequency" => validate_frequency(frequency))
    end
    if !isnothing(aggregation_method)
        push!(query, "aggregation_method" => validate_aggregation_method(aggregation_method))
    end
    if !isnothing(output_type)
        push!(query, "output_type" => Int(output_type))
    end
    if length(vintage_dates) > 0
        push!(query, "vintage_dates" => join(vintage_dates, ','))
    end
    http_response = HTTP.get(joinpath(API_URL, "series", "observations"); query)
    return JSON.parse(http_response.body, ObservationsResponse)
end

"""
    release(series_id; <keyword arguments>)

Get the release for the `series_id` series

See [`fred/series/release`](https://fred.stlouisfed.org/docs/api/fred/series_release.html).
"""
function release(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "series_id" => string(series_id),
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get(joinpath(API_URL, "series", "release"); query)
    return JSON.parse(http_response.body, SimpleReleasesResponse)
end

"""
    search(search_text; <keyword arguments>)

Gets the series that match `search_text`

See [`fred/series/search`](https://fred.stlouisfed.org/docs/api/fred/series_search.html).
"""
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
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "search_text" => search_text,
    ]
    if !isnothing(search_type)
        push!(query, "search_type" => validate_search_type(search_type))
    end
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
            "search_rank",
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
        push!(query, "filter_value" => filter_value)
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))  # TODO: maybe validate
    end
    if length(exclude_tag_names) > 0
        push!(query, "exclude_tag_names" => join(exclude_tag_names, ';'))  # TODO: maybe validate
    end
    http_response = HTTP.get(joinpath(API_URL, "series", "search"); query)
    return JSON.parse(http_response.body, SeriesResponse)
end

"""
    search_tags(series_search_text; <keyword arguments>)

Get the tags for a series search

See [`fred/series/search/tags`](https://fred.stlouisfed.org/docs/api/fred/series_search_tags.html).
"""
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
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
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
        push!(query, "tag_group_id" => validate_tag_group_id(tag_group_id))
    end
    if !isnothing(tag_search_text)
        push!(query, "tag_search_text" => tag_search_text)
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
    http_response = HTTP.get(joinpath(API_URL, "series", "search", "tags"); query)
    return JSON.parse(http_response.body, TagsResponse)
end

"""
    search_related_tags(series_search_text, tag_names; <keyword arguments>)

Get the related tags for `tag_names` matching `series_search_text`

See [`fred/series/search/related_tags`](https://fred.stlouisfed.org/docs/api/fred/series_search_related_tags.html).
"""
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
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
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
        push!(query, "tag_group_id" => validate_tag_group_id(tag_group_id))
    end
    if !isnothing(tag_search_text)
        push!(query, "tag_search_text" => tag_search_text)
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
    http_response = HTTP.get(joinpath(API_URL, "series", "search", "related_tags"); query)
    return JSON.parse(http_response.body, TagsResponse)
end

"""
    tags(series_id; <keyword arguments>)

Get tags for the `series_id` series

See [`fred/series/tags`](https://fred.stlouisfed.org/docs/api/fred/series_tags.html).
"""
function tags(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "series_id" => series_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
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
    http_response = HTTP.get(joinpath(API_URL, "series", "tags"); query)
    return JSON.parse(http_response.body, TagsResponse)
end

"""
    updates(; <keyword arguments>)

Get series updates within the last two weeks

See [`fred/series/updates`](https://fred.stlouisfed.org/docs/api/fred/series_updates.html).
"""
function updates(;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    filter_value::Union{Nothing,AbstractString}=nothing,
    start_time::Union{Nothing,DateTime}=nothing,
    end_time::Union{Nothing,DateTime}=nothing,
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
    if !isnothing(filter_value)
        push!(query, "filter_value" => validate_filter_value(filter_value))
    end
    if !isnothing(start_time) && !isnothing(end_time)
        if start_time <= end_time
            # set both
            push!(query, "start_time" => format(start_time, dateformat"yyyymmddHHMM"))
            push!(query, "end_time" => format(end_time, dateformat"yyyymmddHHMM"))
        else
            throw(ArgumentError("start_time cannot be later than end_time"))
        end
    elseif !isnothing(start_time)
        throw(ArgumentError("end_time must be set if using start_time"))
    elseif !isnothing(end_time)
        throw(ArgumentError("start_time must be set if using end_time"))
    end
    http_response = HTTP.get(joinpath(API_URL, "series", "updates"); query)
    return JSON.parse(http_response.body, SeriesResponse)
end

"""
    vintagedates(series_id; <keyword arguments>)

Get historical dates for when the `series_id` series data values were released/revised

See [`fred/series/vintagedates`](https://fred.stlouisfed.org/docs/api/fred/series_vintagedates.html).
"""
function vintagedates(
    series_id::AbstractString;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = Pair{String,Any}[
        "api_key" => get_api_key(api_key),
        "file_type" => "json",
        "series_id" => series_id,
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
    http_response = HTTP.get(joinpath(API_URL, "series", "vintagedates"); query)
    return JSON.parse(http_response.body, VintageDatesResponse)
end

# Allow Series objects to be used in place of series_id strings
for op in (:get, :categories, :observations, :release, :tags, :vintagedates)
    @eval $op(s::Series, args...; kwargs...) = $op(s.id, args...; kwargs...)
end

end  # module
