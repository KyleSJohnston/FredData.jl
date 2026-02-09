using FredData
using Test

@testset "Basic usage" begin
    f = Fred()
    s1 = get_data(f, "GDPC1")
end

@testset "Sanity tests on simple queries" begin
    function sanity_test_on_query_response(id)
        f = Fred()
        s = get_data(f, id)
        @test s.id == id
        @test !isempty(s.data)
    end

    for id in ["GDPC1"]
        sanity_test_on_query_response(id)
    end
end

@testset "Consistent responses from specific vintages" begin
    f = Fred()
    vintage_dates = "2015-01-01"
    s = get_data(f, "GDPC1"; units="chg", vintage_dates=vintage_dates)
    @test size(s.data) == (271, 4)
    @test s.realtime_start == vintage_dates
    @test s.realtime_end == vintage_dates
end

@testset "Bad requests throw exceptions" begin
    f = Fred()
    @test_throws Exception get_data(f, "GDPC1"; limit="foo")
    @test_throws Exception get_data(f, "GDPC1"; vintage_dates="bar")
end

const OUT = IOBuffer()
const TEXT = IOBuffer()
const COMPACT = IOContext(IOBuffer(), :compact => true)

function doshow(obj)
    show(OUT, obj)
    show(TEXT, "text/plain", obj)
    show(COMPACT, obj)
end

@testset "Categories" begin
    cr = FredData.category.get(125)
    @test cr isa CategoryResponse
    doshow(cr)
    c = only(cr.categories)
    @test c isa Category
    doshow(c)
    new_cr = FredData.category.get(c)
    @test only(new_cr.categories) == c

    cr = FredData.category.children(13)
    @test cr isa CategoryResponse
    doshow(cr)
    @test length(cr.categories) == 6
    @test eltype(cr.categories) === Category
    parent_cr = FredData.category.get(13)
    new_children = FredData.category.children(only(parent_cr.categories))
    @test all(new_children.categories .== cr.categories)

    cr = FredData.category.related(32073)
    @test cr isa CategoryResponse
    doshow(cr)
    related = cr.categories
    @test length(related) == 7
    @test all(x -> x.parent_id == 27281, related)

    series_response = FredData.category.series(125)
    doshow(series_response)
    @test series_response.count < 1000
    @test series_response.count == length(series_response.seriess)
    for s in series_response.seriess
        @testset "$(s.title) $(s.id)" begin
            @test startswith(s.id, "BOP") || startswith(s.id, "IEAB") || startswith(s.id, "AITG")
        end
    end

    tags_response = FredData.category.tags(125)
    doshow(tags_response)
    @test tags_response.count < 1000
    @test tags_response.count == length(tags_response.tags)

    tags_response = FredData.category.related_tags(125, ["services", "quarterly"])
    doshow(tags_response)
    @test tags_response.count < 1000
    @test tags_response.count == length(tags_response.tags)
end

@testset "Releases" begin
    releases_response = FredData.releases.get_all()
    doshow(releases_response)
    @test releases_response.count < 1000
    @test releases_response.count == length(releases_response.releases)

    release_dates_response = FredData.releases.dates()
    doshow(release_dates_response)
    @test release_dates_response.count < 1000
    @test release_dates_response.count == length(release_dates_response.release_dates)

    release_response = FredData.release.get(53)
    doshow(release_response)
    @test release_response isa SimpleReleasesResponse
    @test length(release_response.releases) == 1
    @test release_response.releases[1].name == "Gross Domestic Product"

    release_dates_response = FredData.release.dates(82)
    doshow(release_dates_response)
    @test release_dates_response.count < 10000
    @test release_dates_response.count == length(release_dates_response.release_dates)

    release_series_response = FredData.release.series(51)
    doshow(release_series_response)
    @test release_series_response.count < 1000
    @test release_series_response.count == length(release_series_response.seriess)

    sources_response = FredData.release.sources(51)
    doshow(sources_response)
    @test length(sources_response.sources) == 2
    @test all(x -> contains(x.name, "Bureau"), sources_response.sources)

    tags_response = FredData.release.tags(86)
    doshow(tags_response)
    @test tags_response.count < 1000
    @test tags_response.count == length(tags_response.tags)

    related_tags_reponse = FredData.release.related_tags(86, ["sa", "foreign"])
    doshow(related_tags_reponse)
    @test related_tags_reponse.count < 1000
    @test related_tags_reponse.count == length(related_tags_reponse.tags)

    tables_response = FredData.release.tables(53)
    doshow(tables_response)
    @test tables_response isa TableResponse
end

@testset "Series Endpoints" begin
    sr = FredData.series.get("GNPCA")
    @test sr isa SimpleSeriesResponse
    doshow(sr)
    s = only(sr.seriess)
    @test s isa Series
    doshow(s)
    @test s.id == "GNPCA"

    cr = FredData.series.categories("EXJPUS")
    @test cr isa CategoryResponse
    doshow(cr)
    @test length(cr.categories) < 10

    or = FredData.series.observations("GNPCA")
    @test or isa ObservationsResponse
    doshow(or)
    @test or.count < 100_000
    @test or.count == length(or.observations)
    for o in or.observations
        doshow(o)
        @test o.realtime_start == or.realtime_start
        @test o.realtime_end == or.realtime_end
    end

    rr = FredData.series.release("IRA")
    @test rr isa SimpleReleasesResponse
    doshow(rr)
    for r in rr.releases
        doshow(r)
        @test r.realtime_start == rr.realtime_start
        @test r.realtime_end == rr.realtime_end
    end

    sr = FredData.series.search("monetary service index")
    @test sr isa SeriesResponse
    doshow(sr)
    @test sr.count < 1000
    @test sr.count == length(sr.seriess)
    for s in sr.seriess
        doshow(s)
        @test s.realtime_start == sr.realtime_start
        @test s.realtime_end == sr.realtime_end
    end

    tr = FredData.series.search_tags("monetary+service+index")
    @test tr isa TagsResponse
    doshow(tr)
    @test tr.count < 1000
    @test tr.count == length(tr.tags)

    tr = FredData.series.search_related_tags("mortgage+rate", ["30-year", "frb"])
    @test tr isa TagsResponse
    doshow(tr)
    @test tr.count < 1000
    @test tr.count == length(tr.tags)

    tr = FredData.series.tags("STLFSI")
    @test tr isa TagsResponse
    doshow(tr)
    @test tr.count == length(tr.tags)

    sr = FredData.series.updates()
    @test sr isa SeriesResponse
    doshow(sr)
    @test sr.count > 100
    @test sr.limit == 1000
    @test length(sr.seriess) == 1000

    vdr = FredData.series.vintagedates("GNPCA")
    @test vdr isa VintageDatesResponse
    doshow(vdr)
    @test vdr.count == length(vdr.vintage_dates)
end

@testset "Sources Endpoints" begin
    sr = FredData.source.get_all()
    @test sr isa SourcesResponse
    doshow(sr)
    @test sr.count < 1000
    @test sr.offset == 0
    @test sr.count == length(sr.sources)

    ssr = FredData.source.get(1)
    @test ssr isa SimpleSourcesResponse
    doshow(ssr)
    @test length(ssr.sources) == 1

    rr = FredData.source.releases(1)
    @test rr isa ReleasesResponse
    doshow(rr)
    @test rr.count < 1000
    @test rr.limit == 1000
    @test rr.count == length(rr.releases)
end

@testset "Tags Endpoints" begin
    tr = FredData.tags.get_all()
    @test tr isa TagsResponse
    doshow(tr)
    @test tr.count > tr.limit
    @test tr.limit == length(tr.tags)

    tr = FredData.tags.related_tags(["monetary aggregates", "weekly"])
    @test tr isa TagsResponse
    doshow(tr)
    @test tr.count < tr.limit
    @test tr.count == length(tr.tags)

    sr = FredData.tags.series(["slovenia", "food", "oecd"])
    @test sr isa SeriesResponse
    doshow(sr)
    @test sr.count < sr.limit
    @test sr.count == length(sr.seriess)
end
