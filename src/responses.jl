module Responses

using Dates: Date, DateTime
using StructUtils
using ..FredData: FRED_DATE_FORMAT

export Series, SeriesResponse, Tag, TagsResponse

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

@tags struct Tag
    name::String
    group_id::String
    notes::Union{Nothing,String}
    created::DateTime &(json=(dateformat=FRED_DATE_FORMAT,),)
    popularity::Int
    series_count::Int
end

struct TagsResponse
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    tags::Vector{Tag}
end

end  # module
