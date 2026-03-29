//
//  MiniPlayerViewTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import PodcastPlayerApp

@MainActor
final class MiniPlayerViewTests: XCTestCase {

    private var sut: MiniPlayerView!
    private var playerViewModel: PodcastPlayerViewModel!
    private var mockAudioPlayer: MockPodcastAudioPlayerService!

    override func setUp() {
        super.setUp()
        mockAudioPlayer = MockPodcastAudioPlayerService()
        playerViewModel = PodcastPlayerViewModel(audioPlayer: mockAudioPlayer)
        playerViewModel.currentEpisode = makeEpisode(id: 1, title: "Episode Title")
        playerViewModel.currentPodcast = makePodcast(id: 10, title: "Podcast Title")
        sut = MiniPlayerView(playerViewModel: playerViewModel)
    }

    override func tearDown() {
        sut = nil
        playerViewModel = nil
        mockAudioPlayer = nil
        super.tearDown()
    }

    func test_showsEpisodeTitle() throws {
        XCTAssertNoThrow(try sut.inspect().find(text: "Episode Title"))
    }

    func test_showsPodcastTitle() throws {
        XCTAssertNoThrow(try sut.inspect().find(text: "Podcast Title"))
    }

    func test_showsPlayIcon_whenStateIsPaused() throws {
        playerViewModel.playerState = .paused(episodeID: 1)

        let playPauseButton = try controlButtons()[1]
        let imageName = try playPauseButton
            .labelView()
            .image()
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "play.fill")
    }

    func test_showsPlayIcon_whenStateIsIdle() throws {
        playerViewModel.playerState = .idle

        let playPauseButton = try controlButtons()[1]
        let imageName = try playPauseButton
            .labelView()
            .image()
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "play.fill")
    }

    func test_showsPauseIcon_whenStateIsPlaying() throws {
        playerViewModel.playerState = .playing(episodeID: 1)

        let playPauseButton = try controlButtons()[1]
        let imageName = try playPauseButton
            .labelView()
            .image()
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "pause.fill")
    }

    func test_showsProgressView_whenLoading() throws {
        playerViewModel.playerState = .loading(episodeID: 1)

        let playPauseButton = try controlButtons()[1]

        XCTAssertNoThrow(
            try playPauseButton.labelView().find(ViewType.ProgressView.self)
        )
    }

    func test_playPauseButtonIsDisabled_whenLoading() throws {
        playerViewModel.playerState = .loading(episodeID: 1)

        let playPauseButton = try controlButtons()[1]
        XCTAssertTrue(try playPauseButton.isDisabled())
    }

    func test_playPauseButtonIsEnabled_whenNotLoading() throws {
        playerViewModel.playerState = .paused(episodeID: 1)

        let playPauseButton = try controlButtons()[1]
        XCTAssertFalse(try playPauseButton.isDisabled())
    }

    func test_tappingSkipBackward_callsSkipMinus10() throws {
        let skipBackButton = try controlButtons()[0]

        try skipBackButton.tap()

        XCTAssertTrue(mockAudioPlayer.skipCalled)
        XCTAssertEqual(mockAudioPlayer.skippedSeconds, -10)
    }

    func test_tappingPlayPause_whenPaused_callsResume() throws {
        playerViewModel.playerState = .paused(episodeID: 1)

        let playPauseButton = try controlButtons()[1]

        try playPauseButton.tap()

        XCTAssertTrue(mockAudioPlayer.playCalled)

        guard case .playing(let episodeID) = playerViewModel.playerState else {
            return XCTFail("Expected playerState to be .playing")
        }
        XCTAssertEqual(episodeID, 1)
    }

    func test_tappingPlayPause_whenPlaying_callsPause() throws {
        playerViewModel.playerState = .playing(episodeID: 1)

        let playPauseButton = try controlButtons()[1]

        try playPauseButton.tap()

        XCTAssertTrue(mockAudioPlayer.pauseCalled)

        guard case .paused(let episodeID) = playerViewModel.playerState else {
            return XCTFail("Expected playerState to be .paused")
        }
        XCTAssertEqual(episodeID, 1)
    }

    func test_tappingSkipForward_callsSkipPlus10() throws {
        let skipForwardButton = try controlButtons()[2]

        try skipForwardButton.tap()

        XCTAssertTrue(mockAudioPlayer.skipCalled)
        XCTAssertEqual(mockAudioPlayer.skippedSeconds, 10)
    }

    // MARK: - Helpers

    private func controlButtons() throws -> [InspectableView<ViewType.Button>] {
        let buttons = try sut.inspect().findAll(ViewType.Button.self)
        XCTAssertGreaterThanOrEqual(buttons.count, 3, "Expected 3 control buttons")
        return Array(buttons.suffix(3))
    }

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
        title: String = "Episode Title",
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