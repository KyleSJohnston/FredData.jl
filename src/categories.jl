module Categories

using Dates: Date, DateTime
using HTTP
using JSON
using Logging
using StructUtils

using ..APIKey
using ..FredData: API_KEY_LENGTH, FRED_DATE_FORMAT, KEY_ENV_NAME, key_file

struct Category
    id::Int
    name::String
    parent_id::Int
end

struct CategoryResponse
    categories::Vector{Category}
end

function category(
    category_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "category_id" => category_id,
    ]
    http_response = HTTP.get("https://api.stlouisfed.org/fred/category"; query)
    category_response = JSON.parse(http_response.body, CategoryResponse)
    return only(category_response.categories)
end

function children(
    category_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "category_id" => category_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/category/children"; query)
    category_response = JSON.parse(http_response.body, CategoryResponse)
    return category_response.categories
end

function related(
    category_id::Integer;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
        "category_id" => category_id,
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    http_response = HTTP.get("https://api.stlouisfed.org/fred/category/related"; query)
    category_response = JSON.parse(http_response.body, CategoryResponse)
    return category_response.categories
end

@tags struct Series
    id::String
    realtime_start::Date
    realtime_end::Date
    title::String
    observation_start::Date
    observation_end::Date
    frequency::String
    frequency_short::String
    units::String
    units_short::String
    seasonal_adjustment::String
    seasonal_adjustment_short::String
    last_updated::DateTime &(json=(dateformat=FRED_DATE_FORMAT,),)
    popularity::Int
    group_popularity::Int
    notes::String
end

struct SeriesResponse
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    seriess::Vector{Series}
end

function series(
    category_id::Integer;
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
        "category_id" => category_id,
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/category/series"; query)
    series_response = JSON.parse(http_response.body, SeriesResponse)
    return series_response
end

for op in (:category, :children, :related, :series)
    @eval $op(c::Category; kwargs...) = $op(c.id; kwargs...)
end

end  # module
