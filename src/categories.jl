module Categories

using Dates: Date
using HTTP
using JSON
using Logging
using ..APIKey
using ..FredData: API_KEY_LENGTH, KEY_ENV_NAME, key_file

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

for op in (:category, :children)
    @eval $op(c::Category; kwargs...) = $op(c.id; kwargs...)
end

end  # module
