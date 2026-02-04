module tags

using Dates: Date
using HTTP
using JSON

using ..APIKey
using ..Responses: SeriesResponse, TagsResponse

public get_all, related_tags, series

function get_all(;
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    tag_names::AbstractVector{<:AbstractString}=String[],
    tag_group_id::Union{Nothing,AbstractString}=nothing,
    search_text::Union{Nothing,AbstractString}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
    filter_variable::Union{Nothing,AbstractString}=nothing,
    filter_value::Union{Nothing,AbstractString}=nothing,
    exclude_tag_names::AbstractVector{<:AbstractString}=String[],
)
    query = Pair{String,Any}[
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
    ]
    if !isnothing(realtime_start)
        push!(query, "realtime_start" => string(realtime_start))
    end
    if !isnothing(realtime_end)
        push!(query, "realtime_end" => string(realtime_end))
    end
    if length(tag_names) > 0
        push!(query, "tag_names" => join(tag_names, ';'))  # TODO: maybe validate
    end
    if !isnothing(tag_group_id)
        push!(query, "tag_group_id" => tag_group_id)
    end
    if !isnothing(search_text)
        push!(query, "search_text" => search_text)
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/tags"; query)
    return JSON.parse(http_response.body, TagsResponse)
end

function related_tags(
    tag_names::AbstractVector{<:AbstractString}=String[];
    api_key::Union{Nothing,AbstractString}=nothing,
    realtime_start::Union{Nothing,Date}=nothing,
    realtime_end::Union{Nothing,Date}=nothing,
    exclude_tag_names::AbstractVector{<:AbstractString}=String[],
    tag_group_id::Union{Nothing,AbstractString}=nothing,
    search_text::Union{Nothing,AbstractString}=nothing,
    limit::Union{Nothing,Integer}=nothing,
    offset::Union{Nothing,Integer}=nothing,
    order_by::Union{Nothing,AbstractString}=nothing,
    sort_order::Union{Nothing,AbstractString}=nothing,
)
    query = [
        "api_key" => APIKey.get(api_key),
        "file_type" => "json",
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
        push!(query, "tag_group_id" => string(tag_group_id))
    end
    if !isnothing(search_text)
        push!(query, "search_text" => string(search_text))
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/related_tags"; query)
    return JSON.parse(http_response.body, TagsResponse)
end

function series(
    tag_names::AbstractVector{<:AbstractString}=String[];
    api_key::Union{Nothing,AbstractString}=nothing,
    exclude_tag_names::AbstractVector{<:AbstractString}=String[],
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
        "tag_names" => join(tag_names, ';'),
    ]
    if length(exclude_tag_names) > 0
        push!(query, "exclude_tag_names" => join(exclude_tag_names, ';'))  # TODO: maybe validate
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
    http_response = HTTP.get("https://api.stlouisfed.org/fred/tags/series"; query)
    return JSON.parse(http_response.body, SeriesResponse)
end


end  # module
