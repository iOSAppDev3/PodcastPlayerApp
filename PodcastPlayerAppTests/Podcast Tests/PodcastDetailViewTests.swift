//
//  PodcastDetailViewTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import PodcastPlayerApp

final class PodcastDetailViewTests: XCTestCase {

    func test_showsPodcastTitle() throws {
        let podcast = makePodcast(title: "The Rest Is Politics")

        let sut = PodcastDetailView(
            podcast: podcast,
            isCurrentEpisode: false,
            isPlaying: false,
            onPlayTapped: {}
        )

        let text = try sut.inspect().find(text: "The Rest Is Politics").string()
        XCTAssertEqual(text, "The Rest Is Politics")
    }

    func test_showsPodcastAuthor() throws {
        let podcast = makePodcast(author: "Goalhanger")

        let sut = PodcastDetailView(
            podcast: podcast,
            isCurrentEpisode: false,
            isPlaying: false,
            onPlayTapped: {}
        )

        let text = try sut.inspect().find(text: "Goalhanger").string()
        XCTAssertEqual(text, "Goalhanger")
    }

    func test_showsPodcastDescription() throws {
        let podcast = makePodcast(description: "A politics podcast")

        let sut = PodcastDetailView(
            podcast: podcast,
            isCurrentEpisode: false,
            isPlaying: false,
            onPlayTapped: {}
        )

        let text = try sut.inspect().find(text: "A politics podcast").string()
        XCTAssertEqual(text, "A politics podcast")
    }

    func test_buttonShowsPlayIcon_whenEpisodeIsNotCurrent() throws {
        let sut = PodcastDetailView(
            podcast: makePodcast(),
            isCurrentEpisode: false,
            isPlaying: false,
            onPlayTapped: {}
        )

        let imageName = try playButtonIconName(from: sut)
        XCTAssertEqual(imageName, "play.fill")
    }

    func test_buttonShowsPlayIcon_whenEpisodeIsCurrentButNotPlaying() throws {
        let sut = PodcastDetailView(
            podcast: makePodcast(),
            isCurrentEpisode: true,
            isPlaying: false,
            onPlayTapped: {}
        )

        let imageName = try playButtonIconName(from: sut)
        XCTAssertEqual(imageName, "play.fill")
    }

    func test_buttonShowsPauseIcon_whenEpisodeIsCurrentAndPlaying() throws {
        let sut = PodcastDetailView(
            podcast: makePodcast(),
            isCurrentEpisode: true,
            isPlaying: true,
            onPlayTapped: {}
        )

        let imageName = try playButtonIconName(from: sut)
        XCTAssertEqual(imageName, "pause.fill")
    }

    func test_buttonShowsLatestEpisodeText() throws {
        let sut = PodcastDetailView(
            podcast: makePodcast(),
            isCurrentEpisode: false,
            isPlaying: false,
            onPlayTapped: {}
        )

        let button = try sut.inspect().find(ViewType.Button.self)
        let labelText = try button.labelView().hStack().find(text: "Latest Episode").string()

        XCTAssertEqual(labelText, "Latest Episode")
    }

    func test_tappingPlayButton_callsOnPlayTapped() throws {
        var tapped = false

        let sut = PodcastDetailView(
            podcast: makePodcast(),
            isCurrentEpisode: false,
            isPlaying: false,
            onPlayTapped: {
                tapped = true
            }
        )

        try sut.inspect().find(ViewType.Button.self).tap()

        XCTAssertTrue(tapped)
    }

    // MARK: - Helpers

    private func playButtonIconName(from view: PodcastDetailView) throws -> String {
        let button = try view.inspect().find(ViewType.Button.self)
        let hStack = try button.labelView().hStack()
        return try hStack.find(ViewType.Image.self).actualImage().name()
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
}