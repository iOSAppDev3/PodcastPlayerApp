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

    ///  The API service used to fetch episode data.
    private let podcastAPI: PodcastAPIProtocol

    /// Creates a new view model instance.
    ///
    /// - Parameters:
    ///   - podcast: The podcast whose episodes should be displayed.
    ///   - podcastAPI: The API service used to fetch episode data.
    init(podcast: Podcast, podcastAPI: PodcastAPIProtocol) {
        self.podcast = podcast
        self.podcastAPI = podcastAPI
    }

    /// Loads episodes for the  podcast id.
    ///
    /// This method updates the loading state, clears any previous errors,
    /// and fetches episodes from the API. On failure, an error message is given.
    func loadEpisodes() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }

        do {
            episodes = try await podcastAPI.fetchEpisodes(for: podcast.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
