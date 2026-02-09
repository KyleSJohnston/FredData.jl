using .series: get as series_func, observations as observations_func

function formatnotes(notes::String)
    return strip(
        replace(
            replace(
                notes,
                r"[\r\n]" => " ",
            ),
            r" +" => " ",
        )
    )
end

# TODO: consider f::Fred argument
# TODO: revise docstring
"""
```
get_data(f::Fred, series::AbstractString; kwargs...)
```

Request one series using the FRED API.

### Arguments
- `f`: Fred connection object
- `series`: series mnemonic

### Optional Arguments
`kwargs...`: key-value pairs to be appended to the FRED request. Accepted keys include:

- `realtime_start`: the start of the real-time period as YYYY-MM-DD string
- `realtime_end`: the end of the real-time period as YYYY-MM-DD string
- `limit`: maximum number of results to return
- `offset`: non-negative integer
- `sort_order`: `"asc"`, `"desc"`
- `observation_start`: the start of the observation period as YYYY-MM-DD string
- `observation_end`: the end of the observation period as YYYY-MM-DD string
- `units`: one of `"lin"`, `"chg"`, `"ch1"`, `"pch"`, `"pc1"`, `"pca"`, `"cch"`, `"cca"`,
  `"log"`
- `frequency`: one of `"d"`, `"w"`, `"bw"`, `"m"`, `"q"`, `"sa"`, `"a"`, `"wef"`,
  `"weth"`, `"wew"`, `"wetu"`, `"wem"`, `"wesu"`, `"wesa"`, `"bwew"`, `"bwem"`
- `aggregation_method`: one of `"avg"`, `"sum"`, `"eop"`
- `output_type`: one of `1` (obsevations by real-time period), `2` (observations by vintage
  date, all observations), `3` (observations by vintage date, new and revised observations
  only), `4` (observations, initial release only)
- `vintage_dates`: vintage dates as comma-separated YYYY-MM-DD strings
"""
function get_data(::Fred, series::AbstractString; kwargs...)
    # Query observations. Expand query dict with kwargs. Do this first so we can use the
    # calculated realtime values for the metadata request.
    obs = observations_func(series; kwargs...)::ObservationsResponse
    df = parse_observations(obs)

    # Query metadata
    meta = series_func(
        series;
        realtime_start=obs.realtime_start,
        realtime_end=obs.realtime_end,
    )::SimpleSeriesResponse
    s = first(meta.seriess)
    # TODO catch StatusError and just return incomplete data to the caller

    return FredSeries(
        s.id,
        s.title,
        s.units_short,
        s.units,
        s.seasonal_adjustment_short,
        s.seasonal_adjustment,
        s.frequency_short,
        s.frequency,
        obs.realtime_start,
        obs.realtime_end,
        s.last_updated,
        formatnotes(s.notes),
        obs.units,
        df,
    )
end

parsefloat(x::AbstractString) = something(tryparse(Float64, x), NaN)

function parse_observations(obs::ObservationsResponse)
    df = DataFrame(obs.observations)
    df[!, :value] = parsefloat.(df[!, :value])
    metadata!(df, "realtime_start", obs.realtime_start)
    metadata!(df, "realtime_end", obs.realtime_end)
    metadata!(df, "observation_start", obs.observation_start)
    metadata!(df, "observation_end", obs.observation_end)
    # TODO: consider output_type
    metadata!(df, "order_by", obs.order_by)
    metadata!(df, "sort_order", obs.sort_order)
    metadata!(df, "limit", obs.limit)
    colmetadata!(df, :value, "units", obs.units)
    return df
end
