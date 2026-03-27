//
//  EpisodeListViewModel.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

@MainActor
final class EpisodeListViewModel: ObservableObject {
    @Published private(set) var podcast: Podcast
    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let podcastAPI: PodcastAPIProtocol

    init(podcast: Podcast, podcastAPI: PodcastAPIProtocol) {
        self.podcast = podcast
        self.podcastAPI = podcastAPI
    }

    func loadEpisodes() async {
        isLoading = true
        errorMessage = nil

        do {
            episodes = try await podcastAPI.fetchEpisodes(for: podcast.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
