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

@testset "Categories" begin
    cr = category(125)
    @test cr isa CategoryResponse
    c = only(cr.categories)
    @test c isa Category
    new_cr = category(c)
    @test only(new_cr.categories) == c

    cr = category_children(13)
    @test cr isa CategoryResponse
    @test length(cr.categories) == 6
    @test eltype(cr.categories) === Category
    parent_cr = category(13)
    new_children = category_children(only(parent_cr.categories))
    @test all(new_children.categories .== cr.categories)

    cr = category_related(32073)
    @test cr isa CategoryResponse
    related = cr.categories
    @test length(related) == 7
    @test all(x -> x.parent_id == 27281, related)

    series_response = category_series(125)
    @test series_response.count < 1000
    @test series_response.count == length(series_response.seriess)
    for s in series_response.seriess
        @testset "$(s.title) $(s.id)" begin
            @test startswith(s.id, "BOP") || startswith(s.id, "IEAB") || startswith(s.id, "AITG")
        end
    end

    tags_response = category_tags(125)
    @test tags_response.count < 1000
    @test tags_response.count == length(tags_response.tags)

    tags_response = category_related_tags(125, ["services", "quarterly"])
    @test tags_response.count < 1000
    @test tags_response.count == length(tags_response.tags)
end

@testset "Releases" begin
    releases_response = releases()
    @test releases_response.count < 1000
    @test releases_response.count == length(releases_response.releases)

    release_dates_response = releases_dates()
    @test release_dates_response.count < 1000
    @test release_dates_response.count == length(release_dates_response.release_dates)

    release = FredData.release(53)
    @test release isa Release
    @test release.name == "Gross Domestic Product"

    release_dates_response = release_dates(82)
    @test release_dates_response.count < 10000
    @test release_dates_response.count == length(release_dates_response.release_dates)

    release_series_response = release_series(51)
    @test release_series_response.count < 1000
    @test release_series_response.count == length(release_series_response.seriess)

    sources_response = release_sources(51)
    @test length(sources_response.sources) == 2
    @test all(x -> contains(x.name, "Bureau"), sources_response.sources)

    tags_response = release_tags(86)
    @test tags_response.count < 1000
    @test tags_response.count == length(tags_response.tags)

    related_tags_reponse = release_related_tags(86, ["sa", "foreign"])
    @test related_tags_reponse.count < 1000
    @test related_tags_reponse.count == length(related_tags_reponse.tags)

    tables_response = release_tables(53)
    @test tables_response isa TableResponse
end

@testset "Series Endpoints" begin
    sr = series("GNPCA")
    @test sr isa FredData.SeriesEndpoints.SeriesResponse
    s = only(sr.seriess)
    @test s isa FredData.SeriesEndpoints.Series
    @test s.id == "GNPCA"
end

nothing
