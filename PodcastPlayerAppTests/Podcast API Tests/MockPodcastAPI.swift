//
//  MockPodcastAPI.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import Foundation
@testable import PodcastPlayerApp

final class MockPodcastAPI: PodcastAPIProtocol {
    var podcastListResult: Result<[Podcast], Error> = .success([])
    var podcastResult: Result<Podcast, Error> = .failure(PodcastAppError.invalidResponse)
    var episodesResult: Result<[Episode], Error> = .success([])

    func fetchPodcastList() async throws -> [Podcast] {
        try podcastListResult.get()
    }

    func fetchPodcast(id: Int) async throws -> Podcast {
        try podcastResult.get()
    }

    func fetchEpisodes(for podcastID: Int) async throws -> [Episode] {
        try episodesResult.get()
    }
}