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
    var delayNanoseconds: UInt64 = 0

    func fetchPodcastList() async throws -> [Podcast] {
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return try podcastListResult.get()
    }

    func fetchPodcast(id: Int) async throws -> Podcast {
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return try podcastResult.get()
    }

    func fetchEpisodes(for podcastID: Int) async throws -> [Episode] {
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return try episodesResult.get()
    }
}
