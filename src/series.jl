module series

using Dates: Date, DateTime
using HTTP
using JSON
using StructUtils

using ..APIKey
using ..FredData: FRED_DATE_FORMAT

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

end  # module
