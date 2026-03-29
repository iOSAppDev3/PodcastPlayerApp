//
//  PodcastPlayerViewTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import PodcastPlayerApp

@MainActor
final class PodcastPlayerViewTests: XCTestCase {

    private var sut: PodcastPlayerView!
    private var playerViewModel: PodcastPlayerViewModel!
    private var mockAudioPlayer: MockPodcastAudioPlayerService!

    override func setUp() {
        super.setUp()
        mockAudioPlayer = MockPodcastAudioPlayerService()
        playerViewModel = PodcastPlayerViewModel(audioPlayer: mockAudioPlayer)
        sut = PodcastPlayerView(playerViewModel: playerViewModel)
    }

    override func tearDown() {
        sut = nil
        playerViewModel = nil
        mockAudioPlayer = nil
        super.tearDown()
    }

    func test_showsCurrentEpisodeTitle_whenEpisodeExists() throws {
        playerViewModel.currentEpisode = makeEpisode(title: "Test Episode")
        playerViewModel.currentPodcast = makePodcast()

        let text = try sut.inspect().find(text: "Test Episode").string()
        XCTAssertEqual(text, "Test Episode")
    }

    func test_showsFallbackTitle_whenNoEpisodeExists() throws {
        playerViewModel.currentEpisode = nil
        playerViewModel.currentPodcast = nil

        let text = try sut.inspect().find(text: "No episode playing").string()
        XCTAssertEqual(text, "No episode playing")
    }

    func test_showsFormattedCurrentAndDurationTimes() throws {
        playerViewModel.currentTime = 65
        playerViewModel.duration = 125

        XCTAssertNoThrow(try sut.inspect().find(text: "01:05"))
        XCTAssertNoThrow(try sut.inspect().find(text: "02:05"))
    }

    func test_tappingSkipBackwardButton_callsSkipWithMinus10() throws {
        let buttons = try sut.inspect().findAll(ViewType.Button.self)

        XCTAssertGreaterThanOrEqual(buttons.count, 4)

        try buttons[1].tap()

        XCTAssertTrue(mockAudioPlayer.skipCalled)
        XCTAssertEqual(mockAudioPlayer.skippedSeconds, -10)
    }

    func test_tappingPlayPauseButton_callsTogglePlayPause() throws {
        playerViewModel.currentEpisode = makeEpisode(id: 1)
        playerViewModel.playerState = .paused(episodeID: 1)

        let buttons = try sut.inspect().findAll(ViewType.Button.self)

        XCTAssertGreaterThanOrEqual(buttons.count, 4)

        try buttons[2].tap()

        XCTAssertTrue(mockAudioPlayer.playCalled)
    }

    func test_tappingSkipForwardButton_callsSkipWith10() throws {
        let buttons = try sut.inspect().findAll(ViewType.Button.self)

        XCTAssertGreaterThanOrEqual(buttons.count, 4)

        try buttons[3].tap()

        XCTAssertTrue(mockAudioPlayer.skipCalled)
        XCTAssertEqual(mockAudioPlayer.skippedSeconds, 10)
    }

    func test_showsPauseIcon_whenPlayerIsPlaying() throws {
        playerViewModel.currentEpisode = makeEpisode(id: 1)
        playerViewModel.playerState = .playing(episodeID: 1)

        let buttons = try sut.inspect().findAll(ViewType.Button.self)
        let playPauseButton = buttons[2]

        let imageName = try playPauseButton
            .labelView()
            .image()
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "pause.circle.fill")
    }

    func test_showsPlayIcon_whenPlayerIsNotPlaying() throws {
        playerViewModel.currentEpisode = makeEpisode(id: 1)
        playerViewModel.playerState = .paused(episodeID: 1)

        let buttons = try sut.inspect().findAll(ViewType.Button.self)
        let playPauseButton = buttons[2]

        let imageName = try playPauseButton
            .labelView()
            .image()
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "play.circle.fill")
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
