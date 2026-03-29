//
//  PodcastListViewModelTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
@testable import PodcastPlayerApp

@MainActor
final class PodcastListViewModelTests: XCTestCase {

    private var mockAPI: MockPodcastAPI!
    private var sut: PodcastListViewModel!

    override func setUp() {
        super.setUp()
        mockAPI = MockPodcastAPI()
        sut = PodcastListViewModel(podcastAPI: mockAPI)
    }

    override func tearDown() {
        sut = nil
        mockAPI = nil
        super.tearDown()
    }

    func test_loadPodcastList_setsPodcastList_onSuccess() async {
        let podcasts = [makePodcast(id: 1), makePodcast(id: 2)]
        mockAPI.podcastListResult = .success(podcasts)

        await sut.loadPodcastList()

        XCTAssertEqual(sut.podcastList.count, 2)
        XCTAssertEqual(sut.podcastList.map(\.id), [1, 2])
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadPodcastList_setsErrorMessage_onFailure() async {
        mockAPI.podcastListResult = .failure(PodcastAppError.invalidResponse)

        await sut.loadPodcastList()

        XCTAssertTrue(sut.podcastList.isEmpty)
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
}