module series

using Dates: Date, DateTime
using HTTP
using JSON
using StructUtils

using ..APIKey
using ..FredData: FRED_DATE_FORMAT
using ..Responses: CategoryResponse, ObservationsResponse

export series

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
    popularity::Int  # no group_popularity
    notes::String
end

struct SeriesResponse
    realtime_start::Date
    realtime_end::Date
    seriess::Vector{Series}
end

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
    return JSON.parse(http_response.body, SeriesResponse)
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

end  # module
