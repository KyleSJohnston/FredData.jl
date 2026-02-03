module Releases

using Dates: Date, DateTime
using HTTP
using JSON

using ..APIKey

struct Release
    id::Int
    realtime_start::Date
    realtime_end::Date
    name::String
    press_release::Bool
    link::Union{Nothing,String}
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

struct ReleaseDate
    release_id::Int
    release_name::String
    date::Date
end

struct ReleaseDatesResponse
    realtime_start::Date
    realtime_end::Date
    order_by::String
    sort_order::String
    count::Int
    offset::Int
    limit::Int
    release_dates::Vector{ReleaseDate}
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
    release_dates_response = JSON.parse(http_response.body, ReleaseDatesResponse)
    return release_dates_response
end


# Allow Release objects to be used in place of release_id integers
for op in (:release, )
    @eval $op(r::Release; kwargs...) = $op(r.id; kwargs...)
end

end  # module
