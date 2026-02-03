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

# @testset "Categories" begin
#     category = FredData.Categories.category(125)
#     @test category isa FredData.Categories.Category
#     new_category = FredData.Categories.category(category)
#     @test new_category == category

#     children = FredData.Categories.children(13)
#     @test length(children) == 6
#     @test eltype(children) === FredData.Categories.Category
#     parent = FredData.Categories.category(13)
#     new_children = FredData.Categories.children(parent)
#     @test all(new_children .== children)

#     related = FredData.Categories.related(32073)
#     @test length(related) == 7
#     @test all(x -> x.parent_id == 27281, related)

#     series_response = FredData.Categories.series(125)
#     @test series_response.count < 1000
#     @test series_response.count == length(series_response.seriess)
#     for s in series_response.seriess
#         @testset "$(s.title) $(s.id)" begin
#             @test startswith(s.id, "BOP") || startswith(s.id, "IEAB") || startswith(s.id, "AITG")
#         end
#     end

#     tags_response = FredData.Categories.tags(125)
#     @test tags_response.count < 1000
#     @test tags_response.count == length(tags_response.tags)

#     tags_response = FredData.Categories.related_tags(125; tag_names=["services", "quarterly"])
#     @test tags_response.count < 1000
#     @test tags_response.count == length(tags_response.tags)
# end

@testset "Releases" begin
    release = FredData.Releases.release(53)
    @test release isa FredData.Releases.Release
    @test release.name == "Gross Domestic Product"

    releases_response = FredData.Releases.releases()
    @test releases_response.count < 1000
    @test releases_response.count == length(releases_response.releases)

    release_dates_response = FredData.Releases.dates()
    @test release_dates_response.count < 1000
    @test release_dates_response.count == length(release_dates_response.release_dates)
end

nothing
