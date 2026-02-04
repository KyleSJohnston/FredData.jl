module Responses

using Dates: Date, DateTime
using StructUtils
using ..FredData: FRED_DATE_FORMAT

export Category, CategoryResponse
export Observation, ObservationsResponse
export Release, ReleaseResponse, ReleasesResponse
export ReleaseDate, NamedReleaseDate, ReleaseDatesResponse
export Series, SeriesResponse, SingleSeriesResponse
export Source, SourcesResponse
export TableElement, TableResponse
export Tag, TagsResponse
export VintageDatesResponse

struct Category
    id::Int
    name::String
    parent_id::Int
end

"""

# Returned By:
- `category`
- `category/children`
- `category/related`
- `series/categories`
"""
struct CategoryResponse
    categories::Vector{Category}
end

struct Observation
    realtime_start::Date
    realtime_end::Date
    date::Date
    value::String
end

struct ObservationsResponse
    realtime_start::Date
    realtime_end::Date
    observation_start::Date
    observation_end::Date
    units::String
    output_type::Int
    file_type::String
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    observations::Vector{Observation}
end

struct Release
    id::Int
    realtime_start::Date
    realtime_end::Date
    name::String
    press_release::Bool
    link::Union{Nothing,String}
end

"""

# Returned By:
- `releases`
"""
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

struct ReleaseDate
    release_id::Int
    date::Date
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

struct ReleaseResponse
    realtime_start::Date
    realtime_end::Date
    releases::Vector{Release}
end


@defaults struct Series
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
    group_popularity::Union{Nothing,Int} = nothing
    notes::Union{Nothing,String} = nothing
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

struct SingleSeriesResponse
    realtime_start::Date
    realtime_end::Date
    seriess::Vector{Series}
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

struct VintageDatesResponse
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    vintage_dates::Vector{Date}
end

end  # module
