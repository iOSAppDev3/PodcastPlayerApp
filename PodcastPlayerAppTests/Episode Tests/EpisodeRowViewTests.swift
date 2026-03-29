//
//  EpisodeRowViewTests.swift
//  PodcastPlayerAppTests
//
//  Created by Bakkiya Murugan on 29/03/2026.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import PodcastPlayerApp

final class EpisodeRowViewTests: XCTestCase {

    func test_showsPlayIcon_whenStateIsIdle() throws {
        
        let sut = EpisodeRowView(
            episode: makeEpisode(id: 1),
            playerState: .idle,
            onPlayTapped: {}
        )
        
        let button = try sut.inspect().find(ViewType.Button.self)
        let zStack = try button.labelView().zStack()
        
        let imageName = try zStack
            .image(1) // index 1 = Image (after Circle)
            .actualImage()
            .name()
        
        XCTAssertEqual(imageName, "play.fill")
    }

    func test_showsPauseIcon_whenStateIsPlayingForCurrentEpisode() throws {
        let sut = EpisodeRowView(
            episode: makeEpisode(id: 1),
            playerState: .playing(episodeID: 1),
            onPlayTapped: {}
        )
        
        let button = try sut.inspect().find(ViewType.Button.self)
        let zStack = try button.labelView().zStack()

        let imageName = try zStack
            .image(1) // index 1 = Image (after Circle)
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "pause.fill")
    }

    func test_showsPlayIcon_whenStateIsPausedForCurrentEpisode() throws {
        let sut = EpisodeRowView(
            episode: makeEpisode(id: 1),
            playerState: .paused(episodeID: 1),
            onPlayTapped: {}
        )

        let button = try sut.inspect().find(ViewType.Button.self)
        let zStack = try button.labelView().zStack()

        let imageName = try zStack
            .image(1) // index 1 = Image (after Circle)
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "play.fill")
    }

    func test_buttonIsEnabled_whenStateIsNotLoading() throws {
        let sut = EpisodeRowView(
            episode: makeEpisode(id: 1),
            playerState: .playing(episodeID: 1),
            onPlayTapped: {}
        )

        let isDisabled = try sut.inspect()
            .find(ViewType.Button.self)
            .isDisabled()

        XCTAssertFalse(isDisabled)
    }

    func test_tappingButton_callsOnPlayTapped() throws {
        var tapped = false

        let sut = EpisodeRowView(
            episode: makeEpisode(id: 1),
            playerState: .idle,
            onPlayTapped: {
                tapped = true
            }
        )

        try sut.inspect()
            .find(ViewType.Button.self)
            .tap()

        XCTAssertTrue(tapped)
    }

    func test_loadingOtherEpisode_showsPlayIconForThisEpisode() throws {
        let sut = EpisodeRowView(
            episode: makeEpisode(id: 1),
            playerState: .loading(episodeID: 99),
            onPlayTapped: {}
        )

        XCTAssertThrowsError(
            try sut.inspect().find(ViewType.ProgressView.self)
        )

        let button = try sut.inspect().find(ViewType.Button.self)
        let zStack = try button.labelView().zStack()

        let imageName = try zStack
            .image(1) // index 1 = Image (after Circle)
            .actualImage()
            .name()

        XCTAssertEqual(imageName, "play.fill")
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
