module sources

using Dates: Date
using HTTP
using JSON

using ..APIKey
using ..Responses: SourcesResponse

public get, get_all, releases

function get_all(;
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/sources"; query)
    return JSON.parse(http_response.body, SourcesResponse)
end

end  # module
