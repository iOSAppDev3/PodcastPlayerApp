//
//  EpisodeListViewModelTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
@testable import PodcastPlayerApp

@MainActor
final class EpisodeListViewModelTests: XCTestCase {

    private var mockAPI: MockPodcastAPI!
    private var sut: EpisodeListViewModel!
    private var podcast: Podcast!

    override func setUp() {
        super.setUp()
        mockAPI = MockPodcastAPI()
        podcast = makePodcast(id: 42)
        sut = EpisodeListViewModel(podcast: podcast, podcastAPI: mockAPI)
    }

    override func tearDown() {
        sut = nil
        podcast = nil
        mockAPI = nil
        super.tearDown()
    }

    func test_loadEpisodes_setsEpisodes_onSuccess() async {
        let episodes = [makeEpisode(id: 1), makeEpisode(id: 2)]
        mockAPI.episodesResult = .success(episodes)

        await sut.loadEpisodes()

        XCTAssertEqual(sut.episodes.count, 2)
        XCTAssertEqual(sut.episodes.map(\.id), [1, 2])
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadEpisodes_setsErrorMessage_onFailure() async {
        mockAPI.episodesResult = .failure(PodcastAppError.invalidResponse)

        await sut.loadEpisodes()

        XCTAssertTrue(sut.episodes.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }

    private func makePodcast(
        id: Int = 1,
        author: String = "Author",
        categoryIDs: [Int] = [1],
        description: String = "Description",
        image: String? = nil,
        languageISO: String = "en",
        link: String? = nil,
        original: Bool = false,
        popularity: Double? = nil,
        rss: String = "https://example.com/feed.xml",
        seasonal: Bool = false,
        slug: String = "podcast-\(UUID().uuidString)",
        title: String = "Podcast",
        type: String = "podcast"
    ) -> Podcast {
        Podcast(
            id: id,
            author: author,
            categoryIDs: categoryIDs,
            description: description,
            image: image,
            languageISO: languageISO,
            link: link,
            original: original,
            popularity: popularity,
            rss: rss,
            seasonal: seasonal,
            slug: slug,
            title: title,
            type: type
        )
    }

    private func makeEpisode(
        id: Int = 1,
        description: String = "Episode description",
        duration: Int? = 60,
        encoded: String? = nil,
        episode: Int? = nil,
        exclusive: Bool = false,
        mimeType: String? = "audio/mpeg",
        podcastID: Int = 42,
        published: TimeInterval? = 0,
        season: Int? = nil,
        slug: String = "episode-\(UUID().uuidString)",
        title: String = "Episode",
        type: String = "full",
        url: String? = "https://example.com/audio.mp3"
    ) -> Episode {
        Episode(
            id: id,
            description: description,
            duration: duration,
            encoded: encoded,
            episode: episode,
            exclusive: exclusive,
            mimeType: mimeType,
            podcastID: podcastID,
            published: published,
            season: season,
            slug: slug,
            title: title,
            type: type,
            url: url
        )
    }
}