module Responses

# Custom pretty-printing
# https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing

using Dates: Date, DateTime
using StructUtils
using TimeZones
using ..FredData: FRED_DATE_FORMAT as DATETIME_FORMAT

export Category, CategoryResponse
export Observation, ObservationsResponse
export Release, ReleasesResponse, SimpleReleasesResponse
export ReleaseDate, NamedReleaseDate, ReleaseDatesResponse
export Series, SeriesResponse, SimpleSeriesResponse
export Source, SourcesResponse, SimpleSourcesResponse
export TableElement, TableResponse
export Tag, TagsResponse
export VintageDatesResponse


"""
Element of a CategoryResponse

See [CategoryResponse](@ref)
"""
struct Category
    id::Int
    name::String
    parent_id::Int
end

function Base.show(io::IO, category::Category)
    if get(io, :compact, false)::Bool
        # compact single-line print
        if get(io, :typeinfo, Nothing) == Category
            print(io, category.name)
        else
            print(io, "Category(", category.id, ")")
        end
    else
        # single-line print
        print(
            io,
            "Category(",
            category.id, ", ",
            category.name, ", ",
            category.parent_id, ")"
        )
    end
end

"""
Response containing data categories

# Returned By:
- `category`
- `category/children`
- `category/related`
- `series/categories`
"""
struct CategoryResponse
    categories::Vector{Category}
end

function Base.show(io::IO, cr::CategoryResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "CategoryResponse(<", length(cr.categories), " categories>]")
    else
        # single-line print
        print(io, "CategoryResponse(")
        print(IOContext(io, :compact => true), cr.categories)
        print(io, ")")
    end
end

"""
Element of an ObservationsResponse

See [ObservationsResponse](@ref)
"""
struct Observation
    realtime_start::Date
    realtime_end::Date
    date::Date
    value::String
end

function Base.show(io::IO, observation::Observation)
    if get(io, :compact, false)::Bool
        # compact single-line print
        if get(io, :typeinfo, Nothing) == Observation
            print(io, "(", observation.date, ", ", observation.value, ")")
        else
            print(io, "Observation(", observation.date, ", ", observation.value, ")")
        end
    else
        # single-line print
        print(
            io,
            "Observation(",
            observation.realtime_start, ", ",
            observation.realtime_end, ", ",
            observation.date, ", ",
            observation.value, ")"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", observation::Observation)
    # multi-line print
    println(io, "Observation")
    println(io, "  realtime_start: ", observation.realtime_start)
    println(io, "    realtime_end: ", observation.realtime_end)
    println(io, "            date: ", observation.date)
    println(io, "           value: ", observation.value)
end

"""
Response containing series observations

# Returned By:
- `series/observations`
"""
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

function Base.show(io::IO, or::ObservationsResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "ObservationsResponse(<", length(or.observations), " observations>]")
    else
        # single-line print
        print(
            io,
            "ObservationsResponse(",
            or.realtime_start, ", ",
            or.realtime_end, ", ",
            or.observation_start, ", ",
            or.observation_end, ", <",
            length(or.observations), " observations>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", or::ObservationsResponse)
    # multi-line print
    println(io, "ObservationsResponse")
    println(io, "       realtime_start: ", or.realtime_start)
    println(io, "         realtime_end: ", or.realtime_end)
    println(io, "    observation_start: ", or.observation_start)
    println(io, "      observation_end: ", or.observation_end)
    println(io, "                units: ", or.units)
    println(io, "          output_type: ", or.output_type)
    println(io, "            file_type: ", or.file_type)
    println(io, "             order_by: ", or.order_by)
    println(io, "           sort_order: ", or.sort_order)
    println(io, "                count: ", or.count)
    println(io, "               offset: ", or.offset)
    println(io, "                limit: ", or.limit)
    print(io,   "         observations: ")
    print(IOContext(io, :compact => true), or.observations)
end

"""
Element of a ReleasesResponse or a SimpleReleasesResponse

See [ReleasesResponse](@ref) and [SimpleReleasesResponse](@ref).
"""
struct Release
    id::Int
    realtime_start::Date
    realtime_end::Date
    name::String
    press_release::Bool
    link::Union{Nothing,String}
end

function Base.show(io::IO, release::Release)
    if get(io, :compact, false)::Bool
        # compact single-line print
        if get(io, :typeinfo, Nothing) == Release
            print(io, release.id)
        else
            print(io, "Release(", release.id, ")")
        end
    else
        # single-line print
        print(
            io,
            "Release(",
            release.id, ", ",
            release.realtime_start, ", ",
            release.realtime_end, ", ",
            release.name, ", ",
            release.press_release, ",",
            release.link, ")",
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", release::Release)
    # multi-line print
    println(io, "Release")
    println(io, "              id: ", release.id)
    println(io, "  realtime_start: ", release.realtime_start)
    println(io, "    realtime_end: ", release.realtime_end)
    println(io, "            name: ", release.name)
    println(io, "   press_release: ", release.press_release)
    println(io, "            link: ", release.link)
end

"""
Response containing release information

# Returned By:
- `releases`
- `source/releases`
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

function Base.show(io::IO, rr::ReleasesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "ReleasesResponse(<", length(rr.releases), " releases>]")
    else
        # single-line print
        print(
            io,
            "ReleasesResponse(",
            rr.realtime_start, ", ",
            rr.realtime_end, ", ",
            rr.order_by, ", ",
            rr.sort_order, ", ",
            rr.count, ", ",
            rr.offset, ", ",
            rr.limit, ", <",
            length(rr.releases), " observations>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", rr::ReleasesResponse)
    # multi-line print
    println(io, "ReleasesResponse")
    println(io, "  realtime_start: ", rr.realtime_start)
    println(io, "    realtime_end: ", rr.realtime_end)
    println(io, "        order_by: ", rr.order_by)
    println(io, "      sort_order: ", rr.sort_order)
    println(io, "           count: ", rr.count)
    println(io, "          offset: ", rr.offset)
    println(io, "           limit: ", rr.limit)
    print(io,   "        releases: ")
    print(IOContext(io, :compact => true), rr.releases)
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

function Base.show(io::IO, rdr::ReleaseDatesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "ReleaseDatesResponse(<", length(rdr.release_dates), " release dates>]")
    else
        # single-line print
        print(
            io,
            "ReleaseDatesResponse(",
            rdr.realtime_start, ", ",
            rdr.realtime_end, ", ",
            rdr.order_by, ", ",
            rdr.sort_order, ", ",
            rdr.count, ", ",
            rdr.offset, ", ",
            rdr.limit, ", <",
            length(rdr.release_dates), " release dates>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", rdr::ReleaseDatesResponse)
    # multi-line print
    println(io, "ReleaseDatesResponse")
    println(io, "  realtime_start: ", rdr.realtime_start)
    println(io, "    realtime_end: ", rdr.realtime_end)
    println(io, "        order_by: ", rdr.order_by)
    println(io, "      sort_order: ", rdr.sort_order)
    println(io, "           count: ", rdr.count)
    println(io, "          offset: ", rdr.offset)
    println(io, "           limit: ", rdr.limit)
    print(io,   "   release_dates: ")
    print(IOContext(io, :compact => true), rdr.release_dates)
end

"""
A ReleasesResponse with less metadata

# Returned By:
- `release`
- `series/release`
"""
struct SimpleReleasesResponse
    realtime_start::Date
    realtime_end::Date
    releases::Vector{Release}
end

function Base.show(io::IO, rr::SimpleReleasesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "SimpleReleasesResponse(<", length(rr.releases), " releases>]")
    else
        # single-line print
        print(
            io,
            "SimpleReleasesResponse(",
            rr.realtime_start, ", ",
            rr.realtime_end, ", <",
            length(rr.releases), " releases>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", rr::SimpleReleasesResponse)
    # multi-line print
    println(io, "SimpleReleasesResponse")
    println(io, "  realtime_start: ", rr.realtime_start)
    println(io, "    realtime_end: ", rr.realtime_end)
    print(io,   "        releases: ")
    print(IOContext(io, :compact => true), rr.releases)
end

"""
Element of a `SeriesResponse` or a `SimpleSeriesResponse`

See [SeriesResponse](@ref) and [SimpleSeriesResponse](@ref).
"""
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
    last_updated::DateTime &(json=(dateformat=DATETIME_FORMAT,),)
    popularity::Int
    group_popularity::Union{Nothing,Int} = nothing
    notes::Union{Nothing,String} = nothing
end

function Base.show(io::IO, series::Series)
    if get(io, :compact, false)::Bool
        # compact single-line print
        if get(io, :typeinfo, Nothing) == Series
            print(io, series.id)
        else
            print(io, "Series[", series.id, "]")
        end
    else
        # single-line print
        print(io, "Series(", series.id, ", ", series.title, ", ", series.frequency, ", ", series.units, ")")
    end
end

function Base.show(io::IO, ::MIME"text/plain", series::Series)
    # multi-line print
    println(io, "Series")
    println(io, "                   id: ", series.id)
    println(io, "       realtime_start: ", series.realtime_start)
    println(io, "         realtime_end: ", series.realtime_end)
    println(io, "                title: ", series.title)
    println(io, "    observation_start: ", series.observation_start)
    println(io, "      observation_end: ", series.observation_end)
    println(io, "            frequency: ", series.frequency, " [", series.frequency_short, "]")
    println(io, "                units: ", series.units, " [", series.units_short, "]")
    println(io, "  seasonal_adjustment: ", series.seasonal_adjustment, " [", series.seasonal_adjustment_short, "]")
    println(io, "         last_updated: ", series.last_updated)
    println(io, "           popularity: ", series.popularity)
    println(io, "     group_popularity: ", series.group_popularity)
    println(io, "                notes:")
    print(io, series.notes)
end

"""
Endpoint response containing one or more series

# Returned By:
- `category/series`
- `release/series`
- `tags/series`
"""
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


function Base.show(io::IO, sr::SeriesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "SeriesResponse(<", length(sr.seriess), " series>]")
    else
        # single-line print
        print(
            io,
            "SeriesResponse(",
            sr.realtime_start, ", ",
            sr.realtime_end, ", ",
            sr.order_by, ", ",
            sr.sort_order, ", ",
            sr.count, ", ",
            sr.offset, ", ",
            sr.limit, ", <",
            length(sr.seriess), " series>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", sr::SeriesResponse)
    # multi-line print
    println(io, "SeriesResponse")
    println(io, "  realtime_start: ", sr.realtime_start)
    println(io, "    realtime_end: ", sr.realtime_end)
    println(io, "        order_by: ", sr.order_by)
    println(io, "      sort_order: ", sr.sort_order)
    println(io, "           count: ", sr.count)
    println(io, "          offset: ", sr.offset)
    println(io, "           limit: ", sr.limit)
    print(io,   "         seriess: ")
    print(IOContext(io, :compact => true), sr.seriess)
end

"""
A `SeriesResponse` with less metadata, often used when only one `Series` is returned

# Returned By:
- `series`
"""
struct SimpleSeriesResponse
    realtime_start::Date
    realtime_end::Date
    seriess::Vector{Series}
end

function Base.show(io::IO, ssr::SimpleSeriesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "SimpleSeriesResponse(<", length(ssr.seriess), " series>]")
    else
        # single-line print
        print(io, "SimpleSeriesResponse(", ssr.realtime_start, ", ", ssr.realtime_end, ", <", length(ssr.seriess), " series>)")
    end
end

function Base.show(io::IO, ::MIME"text/plain", ssr::SimpleSeriesResponse)
    # multi-line print
    println(io, "SimpleSeriesResponse")
    println(io, "  realtime_start: ", ssr.realtime_start)
    println(io, "    realtime_end: ", ssr.realtime_end)
    print(io,   "         seriess: ")
    print(IOContext(io, :compact => true), ssr.seriess)
end

"""
Element of a `SourcesResponse` or a `SimpleSourcesResponse`

Note that `link` and/or `notes` may be omitted.

See [SourcesResponse](@ref) or [SimpleSourcesResponse](@ref).
"""
@defaults struct Source
    id::Int
    realtime_start::Date
    realtime_end::Date
    name::String
    link::Union{Nothing,String} = nothing
    notes::Union{Nothing,String} = nothing
end

"""
Response containing one or more `Source` instances

# Returned By:
- `sources`
"""
struct SourcesResponse
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    sources::Vector{Source}
end


function Base.show(io::IO, sr::SourcesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "SourcesResponse(<", length(sr.sources), " sources>]")
    else
        # single-line print
        print(
            io,
            "SourcesResponse(",
            sr.realtime_start, ", ",
            sr.realtime_end, ", ",
            sr.order_by, ", ",
            sr.sort_order, ", ",
            sr.count, ", ",
            sr.offset, ", ",
            sr.limit, ", <",
            length(sr.sources), " sources>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", sr::SourcesResponse)
    # multi-line print
    println(io, "SourcesResponse")
    println(io, "  realtime_start: ", sr.realtime_start)
    println(io, "    realtime_end: ", sr.realtime_end)
    println(io, "        order_by: ", sr.order_by)
    println(io, "      sort_order: ", sr.sort_order)
    println(io, "           count: ", sr.count)
    println(io, "          offset: ", sr.offset)
    println(io, "           limit: ", sr.limit)
    print(io,   "         sources: ")
    print(IOContext(io, :compact => true), sr.sources)
end

"""
A `SourcesResponse` with less metadata, usually returned when one `Source` is expected

# Returned By:
- `release/sources`
- `source`
"""
struct SimpleSourcesResponse
    realtime_start::Date
    realtime_end::Date
    sources::Vector{Source}
end

function Base.show(io::IO, ssr::SimpleSourcesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "SimpleSourcesResponse(<", length(ssr.sources), " sources>]")
    else
        # single-line print
        print(io, "SimpleSourcesResponse(", ssr.realtime_start, ", ", ssr.realtime_end, ", <", length(ssr.sources), " sources>)")
    end
end

function Base.show(io::IO, ::MIME"text/plain", ssr::SimpleSourcesResponse)
    # multi-line print
    println(io, "SimpleSourcesResponse")
    println(io, "  realtime_start: ", ssr.realtime_start)
    println(io, "    realtime_end: ", ssr.realtime_end)
    print(io,   "         sources: ")
    print(IOContext(io, :compact => true), ssr.sources)
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

"""
Element of a `TagsResponse`

See [TagsResponse](@ref).
"""
@tags struct Tag
    name::String
    group_id::String
    notes::Union{Nothing,String}
    created::DateTime &(json=(dateformat=DATETIME_FORMAT,),)
    popularity::Int
    series_count::Int
end

"""
Endpoint response with one or more `Tag` instances

# Returned By:
- `category/tags`
- `category/related_tags`
- `release/tags`
- `release/related_tags`
- `series/search/tags`
- `series/search/related_tags`
- `series/tags`
- `tags`
- `related_tags`
"""
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

function Base.show(io::IO, tr::TagsResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "TagsResponse(<", length(tr.tags), " tags>]")
    else
        # single-line print
        print(
            io,
            "TagsResponse(",
            tr.realtime_start, ", ",
            tr.realtime_end, ", ",
            tr.order_by, ", ",
            tr.sort_order, ", ",
            tr.count, ", ",
            tr.offset, ", ",
            tr.limit, ", <",
            length(tr.tags), " tags>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", tr::TagsResponse)
    # multi-line print
    println(io, "TagsResponse")
    println(io, "  realtime_start: ", tr.realtime_start)
    println(io, "    realtime_end: ", tr.realtime_end)
    println(io, "        order_by: ", tr.order_by)
    println(io, "      sort_order: ", tr.sort_order)
    println(io, "           count: ", tr.count)
    println(io, "          offset: ", tr.offset)
    println(io, "           limit: ", tr.limit)
    print(io,   "            tags: ")
    print(IOContext(io, :compact => true), tr.tags)
end

"""
Endpoint response for when a series' data values were updated

# Returned By:
- `series/vintagedates`
"""
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


function Base.show(io::IO, vdr::VintageDatesResponse)
    if get(io, :compact, false)::Bool
        # compact single-line print
        print(io, "VintageDatesResponse(<", length(vdr.vintage_dates), " dates>]")
    else
        # single-line print
        print(
            io,
            "VintageDatesResponse(",
            vdr.realtime_start, ", ",
            vdr.realtime_end, ", ",
            vdr.order_by, ", ",
            vdr.sort_order, ", ",
            vdr.count, ", ",
            vdr.offset, ", ",
            vdr.limit, ", <",
            length(vdr.vintage_dates), " dates>)"
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", vdr::VintageDatesResponse)
    # multi-line print
    println(io, "VintageDatesResponse")
    println(io, "  realtime_start: ", vdr.realtime_start)
    println(io, "    realtime_end: ", vdr.realtime_end)
    println(io, "        order_by: ", vdr.order_by)
    println(io, "      sort_order: ", vdr.sort_order)
    println(io, "           count: ", vdr.count)
    println(io, "          offset: ", vdr.offset)
    println(io, "           limit: ", vdr.limit)
    print(io,   "   vintage_dates: ")
    print(IOContext(io, :compact => true), vdr.vintage_dates)
end

end  # module
