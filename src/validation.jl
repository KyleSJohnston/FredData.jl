module Validation

export validate_limit, validate_offset, validate_sort_order,
    validate_filter_variable, validate_tag_group_id, validate_units,
    validate_frequency, validate_aggregation_method, validate_search_type,
    validate_filter_value

function validate_limit(limit::Integer; lbound=1, ubound=1_000)
    lbound <= limit <= ubound || throw(ArgumentError("limit of $limit not between $lbound and $ubound"))
    return limit
end

function validate_offset(offset::Integer)
    offset >= 0 || throw(ArgumentError("offset must be non-negative"))
    return offset
end

# validate_order_by appears to deviate based on the return type of the function
# order_by must be one of the fields in the element type of the response, but
# not all fields are permitted.

function validate_sort_order(sort_order::AbstractString)
    sort_order == "asc" || sort_order == "desc" || throw(ArgumentError("invalid sort_order $sort_order"))
    return String(sort_order)
end

function validate_filter_variable(filter_variable::AbstractString)
    filter_variable == "frequency" ||
        filter_variable == "units" ||
        filter_variable == "seasonal_adjustment" ||
        throw(ArgumentError("invalid filter_variable $filter_variable"))
    return String(filter_variable)
end

function validate_tag_group_id(tag_group_id::AbstractString)
    tag_group_id in (
        "freq",  # frequency
        "gen",   # general or concept
        "geo",   # geography
        "geot",  # geography type
        "rls",   # release
        "seas",  # seasonal adjustment
        "src",   # source
    ) || throw(ArgumentError("invalid tag_group_id $tag_group_id"))
    return String(tag_group_id)
end

function validate_units(units::AbstractString)
    units in (
        "lin",  # levels (no transformation)
        "chg",  # change
        "ch1",  # change from prior year
        "pch",  # percentage change
        "pc1",  # percentage change from prior year
        "pca",  # compounded annual rate of change
        "cch",  # continuously compounded rate of change
        "cca",  # continuously compounded annual rate of change
        "log",  # natural log
    ) || throw(ArgumentError("invalid units $units"))
    return String(units)
end

function validate_frequency(frequency::AbstractString)
    frequency in (
        "d",     # daily
        "w",     # weekly
        "bw",    # biweekly
        "m",     # monthly
        "q",     # quarterly
        "sa",    # semiannual
        "a",     # annual
        "wef",   # weekly, ending Friday
        "weth",  # weekly, ending Thursday
        "wew",   # weekly, ending Wednesday
        "wetu",  # weekly, ending Tuesday
        "wem",   # weekly, ending Monday
        "wesu",  # weekly, ending Sunday
        "wesa",  # weekly, ending Saturday
        "bwew",  # biweekly, ending Wednesday
        "bwem",  # biweekly, ending Monday
    ) || throw(ArgumentError("invalid frequency $frequency"))
    return String(frequency)
end

function validate_aggregation_method(aggregation_method::AbstractString)
    aggregation_method in (
        "avg",  # average
        "sum",  # sum
        "eop",  # end-of-period
    ) || throw(ArgumentError("invalid aggregation_method $aggregation_method"))
    return String(aggregation_method)
end

function validate_search_type(search_type::AbstractString)
    search_type == "full_text" ||
        search_type == "series_id" ||
        throw(ArgumentError("invalid search_type $search_type"))
    return String(search_type)
end

function validate_filter_value(filter_value::AbstractString)
    filter_value in (
        "macro",     # macroeconomic data series
        "regional",  # series for parts of the U.S. (e.g.: states, counties, MSAs)
        "all",       # no filter
    ) || throw(ArgumentError("invalid filter_value $filter_value"))
    return String(filter_value)
end

end  # module
