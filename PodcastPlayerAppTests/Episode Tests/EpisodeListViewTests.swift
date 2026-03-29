//
//  EpisodeListViewTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import PodcastPlayerApp

@MainActor
final class EpisodeListViewTests: XCTestCase {

    override func tearDown() {
        ViewHosting.expel()
        super.tearDown()
    }

    func test_showsLoadingView_whileEpisodesAreLoading() async throws {
        let api = MockPodcastAPI()
        api.episodesResult = .success([makeEpisode(id: 1, title: "Episode 1")])
        api.delayNanoseconds = 300_000_000

        let viewModel = EpisodeListViewModel(
            podcast: makePodcast(),
            podcastAPI: api
        )
        let playerViewModel = PodcastPlayerViewModel(
            audioPlayer: MockPodcastAudioPlayerService()
        )

        let sut = EpisodeListView(viewModel: viewModel)
            .environmentObject(playerViewModel)

        ViewHosting.host(view: sut)

        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNoThrow(try sut.inspect().find(ViewType.ProgressView.self))
        XCTAssertNoThrow(try sut.inspect().find(text: "Loading Episodes..."))
    }

    func test_showsErrorView_whenEpisodeLoadingFails() async throws {
        let api = MockPodcastAPI()
        api.episodesResult = .failure(PodcastAppError.invalidResponse)

        let viewModel = EpisodeListViewModel(
            podcast: makePodcast(),
            podcastAPI: api
        )
        let playerViewModel = PodcastPlayerViewModel(
            audioPlayer: MockPodcastAudioPlayerService()
        )

        let sut = EpisodeListView(viewModel: viewModel)
            .environmentObject(playerViewModel)

        ViewHosting.host(view: sut)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNoThrow(try sut.inspect().find(text: "Unable to load episodes"))
    }

    func test_showsEpisodesSectionAndEpisodeRows_whenLoadingSucceeds() async throws {
        let api = MockPodcastAPI()
        api.episodesResult = .success([
            makeEpisode(id: 1, title: "Episode 1"),
            makeEpisode(id: 2, title: "Episode 2")
        ])

        let viewModel = EpisodeListViewModel(
            podcast: makePodcast(),
            podcastAPI: api
        )
        let playerViewModel = PodcastPlayerViewModel(
            audioPlayer: MockPodcastAudioPlayerService()
        )

        let sut = EpisodeListView(viewModel: viewModel)
            .environmentObject(playerViewModel)

        ViewHosting.host(view: sut)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNoThrow(try sut.inspect().find(text: "Episodes"))
        XCTAssertNoThrow(try sut.inspect().find(text: "Episode 1"))
        XCTAssertNoThrow(try sut.inspect().find(text: "Episode 2"))
    }

    func test_tappingLatestEpisodeButton_playsLatestEpisode() async throws {
        let latestEpisode = makeEpisode(id: 2, title: "Latest Episode Title")
        let olderEpisode = makeEpisode(id: 1, title: "Older Episode Title")

        let api = MockPodcastAPI()
        api.episodesResult = .success([olderEpisode, latestEpisode])

        let mockAudioPlayer = MockPodcastAudioPlayerService()
        let viewModel = EpisodeListViewModel(
            podcast: makePodcast(id: 42),
            podcastAPI: api
        )
        let playerViewModel = PodcastPlayerViewModel(audioPlayer: mockAudioPlayer)

        let sut = EpisodeListView(viewModel: viewModel)
            .environmentObject(playerViewModel)

        ViewHosting.host(view: sut)

        try await Task.sleep(nanoseconds: 100_000_000)

        let latestEpisodeButton = try sut.inspect()
            .find(ViewType.Button.self) { button in
                try button.labelView().find(text: "Latest Episode").string() == "Latest Episode"
            }

        try latestEpisodeButton.tap()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(playerViewModel.currentEpisode?.id, latestEpisode.id)
        XCTAssertEqual(playerViewModel.currentPodcast?.id, 42)
    }

    // MARK: - Helpers

    private func makePodcast(
        id: Int = 1,
        author: String = "Author",
        categoryIDs: [Int] = [1],
        description: String = "Podcast description",
        image: String? = nil,
        languageISO: String = "en",
        link: String? = nil,
        original: Bool = false,
        popularity: Double? = nil,
        rss: String = "https://example.com/feed.xml",
        seasonal: Bool = false,
        slug: String = "podcast-\(UUID().uuidString)",
        title: String = "Podcast Title",
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
