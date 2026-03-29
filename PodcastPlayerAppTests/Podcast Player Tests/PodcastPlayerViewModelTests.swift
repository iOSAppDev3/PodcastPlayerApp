//
//  PodcastPlayerViewModelTests.swift
//  PodcastPlayerAppTests
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import XCTest
@testable import PodcastPlayerApp

@MainActor
final class PodcastPlayerViewModelTests: XCTestCase {

    private var sut: PodcastPlayerViewModel!
    private var mockAudioPlayer: MockPodcastAudioPlayerService!

    override func setUp() {
        super.setUp()
        mockAudioPlayer = MockPodcastAudioPlayerService()
        sut = PodcastPlayerViewModel(audioPlayer: mockAudioPlayer)
    }

    override func tearDown() {
        sut = nil
        mockAudioPlayer = nil
        super.tearDown()
    }

    func test_play_setsPlayingState_onSuccess() async {
        let episode = makeEpisode(id: 1, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 10)

        await sut.play(episode: episode, podcast: podcast)

        XCTAssertEqual(sut.currentEpisode?.id, 1)
        XCTAssertEqual(sut.currentPodcast?.id, 10)
        XCTAssertEqual(sut.duration, 120)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showErrorAlert)
        XCTAssertTrue(mockAudioPlayer.loadAudioCalled)
        XCTAssertTrue(mockAudioPlayer.playCalled)

        guard case .playing(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .playing")
        }
        XCTAssertEqual(episodeID, 1)
    }

    func test_play_setsFailedState_whenURLIsInvalid() async {
        let episode = makeEpisode(id: 1, url: nil)
        let podcast = makePodcast(id: 10)

        await sut.play(episode: episode, podcast: podcast)

        XCTAssertNil(sut.currentEpisode?.id)
        XCTAssertNil(sut.currentPodcast?.id)
        XCTAssertFalse(mockAudioPlayer.loadAudioCalled)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showErrorAlert)

        guard case .failed = sut.playerState else {
            return XCTFail("Expected playerState to be .failed")
        }
    }

    func test_play_setsFailedState_whenLoadAudioThrows() async {
        let episode = makeEpisode(id: 2, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 20)
        mockAudioPlayer.loadAudioError = URLError(.timedOut)

        await sut.play(episode: episode, podcast: podcast)

        XCTAssertEqual(sut.currentEpisode?.id, 2)
        XCTAssertEqual(sut.currentPodcast?.id, 20)
        XCTAssertTrue(mockAudioPlayer.loadAudioCalled)
        XCTAssertFalse(mockAudioPlayer.playCalled)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showErrorAlert)

        guard case .failed(let message) = sut.playerState else {
            return XCTFail("Expected playerState to be .failed")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_pause_setsPausedState_forCurrentEpisode() async {
        let episode = makeEpisode(id: 3, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 30)

        await sut.play(episode: episode, podcast: podcast)
        sut.pause()

        XCTAssertTrue(mockAudioPlayer.pauseCalled)

        guard case .paused(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .paused")
        }
        XCTAssertEqual(episodeID, 3)
    }

    func test_resume_setsPlayingState_forCurrentEpisode() async {
        let episode = makeEpisode(id: 4, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 40)

        await sut.play(episode: episode, podcast: podcast)
        sut.pause()
        mockAudioPlayer.playCalled = false

        sut.resume()

        XCTAssertTrue(mockAudioPlayer.playCalled)

        guard case .playing(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .playing")
        }
        XCTAssertEqual(episodeID, 4)
    }

    func test_togglePlayPause_pauses_whenCurrentlyPlaying() async {
        let episode = makeEpisode(id: 5, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 50)

        await sut.play(episode: episode, podcast: podcast)
        sut.togglePlayPause()

        XCTAssertTrue(mockAudioPlayer.pauseCalled)

        guard case .paused(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .paused")
        }
        XCTAssertEqual(episodeID, 5)
    }

    func test_togglePlayPause_resumes_whenCurrentlyPaused() async {
        let episode = makeEpisode(id: 6, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 60)

        await sut.play(episode: episode, podcast: podcast)
        sut.pause()
        mockAudioPlayer.playCalled = false

        sut.togglePlayPause()

        XCTAssertTrue(mockAudioPlayer.playCalled)

        guard case .playing(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .playing")
        }
        XCTAssertEqual(episodeID, 6)
    }

    func test_togglePlayback_ignoresTap_whenEpisodeIsLoading() async {
        sut.playerState = .loading(episodeID: 7)
        let episode = makeEpisode(id: 7, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 70)

        await sut.togglePlayback(for: episode, podcast: podcast)

        XCTAssertFalse(mockAudioPlayer.playCalled)
        XCTAssertFalse(mockAudioPlayer.pauseCalled)

        guard case .loading(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to remain .loading")
        }
        XCTAssertEqual(episodeID, 7)
    }

    func test_togglePlayback_pauses_whenCurrentEpisodeIsPlaying() async {
        let episode = makeEpisode(id: 8, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 80)

        await sut.play(episode: episode, podcast: podcast)
        mockAudioPlayer.pauseCalled = false

        await sut.togglePlayback(for: episode, podcast: podcast)

        XCTAssertTrue(mockAudioPlayer.pauseCalled)

        guard case .paused(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .paused")
        }
        XCTAssertEqual(episodeID, 8)
    }

    func test_togglePlayback_resumes_whenCurrentEpisodeIsPaused() async {
        let episode = makeEpisode(id: 9, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 90)

        await sut.play(episode: episode, podcast: podcast)
        sut.pause()
        mockAudioPlayer.playCalled = false

        await sut.togglePlayback(for: episode, podcast: podcast)

        XCTAssertTrue(mockAudioPlayer.playCalled)

        guard case .playing(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .playing")
        }
        XCTAssertEqual(episodeID, 9)
    }

    func test_togglePlayback_playsNewEpisode_whenDifferentEpisodeTapped() async {
        let firstEpisode = makeEpisode(id: 10, url: "https://example.com/audio1.mp3")
        let secondEpisode = makeEpisode(id: 11, url: "https://example.com/audio2.mp3")
        let podcast = makePodcast(id: 100)

        await sut.play(episode: firstEpisode, podcast: podcast)
        mockAudioPlayer.playCalled = false
        mockAudioPlayer.loadAudioCalled = false

        await sut.togglePlayback(for: secondEpisode, podcast: podcast)

        XCTAssertEqual(sut.currentEpisode?.id, 11)
        XCTAssertTrue(mockAudioPlayer.loadAudioCalled)
        XCTAssertTrue(mockAudioPlayer.playCalled)

        guard case .playing(let episodeID) = sut.playerState else {
            return XCTFail("Expected playerState to be .playing")
        }
        XCTAssertEqual(episodeID, 11)
    }

    func test_seek_updatesCurrentTime() {
        sut.seek(to: 42)

        XCTAssertTrue(mockAudioPlayer.seekCalled)
        XCTAssertEqual(mockAudioPlayer.seekedTime, 42)
        XCTAssertEqual(sut.currentTime, 42)
    }

    func test_skip_callsAudioPlayer() {
        sut.skip(seconds: 30)

        XCTAssertTrue(mockAudioPlayer.skipCalled)
        XCTAssertEqual(mockAudioPlayer.skippedSeconds, 30)
    }

    func test_play_updatesCurrentTime_whenTimeObserverFires() async {
        let episode = makeEpisode(id: 12, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 120)

        await sut.play(episode: episode, podcast: podcast)
        mockAudioPlayer.timeObserver?(55)

        XCTAssertEqual(sut.currentTime, 55)
    }

    func test_formatTime_returnsFormattedString() {
        XCTAssertEqual(sut.formatTime(125), "02:05")
    }

    func test_formatTime_returnsZeroString_forNaN() {
        XCTAssertEqual(sut.formatTime(.nan), "00:00")
    }

    func test_isCurrentEpisode_returnsTrue_forMatchingEpisode() async {
        let episode = makeEpisode(id: 13, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 130)

        await sut.play(episode: episode, podcast: podcast)

        XCTAssertTrue(sut.isCurrentEpisode(episode))
    }

    func test_isCurrentEpisode_returnsFalse_forNonMatchingEpisode() async {
        let current = makeEpisode(id: 14, url: "https://example.com/audio.mp3")
        let other = makeEpisode(id: 15, url: "https://example.com/audio.mp3")
        let podcast = makePodcast(id: 140)

        await sut.play(episode: current, podcast: podcast)

        XCTAssertFalse(sut.isCurrentEpisode(other))
    }
    
    // MARK: - Helpers

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
