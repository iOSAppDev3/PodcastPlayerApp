//
//  PodcastListViewModel.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

@MainActor
final class PodcastListViewModel: ObservableObject {
    @Published private(set) var podcastList: [Podcast] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    ///  The API service used to fetch episode data.
    private let podcastAPI: PodcastAPIProtocol

    /// Creates a new view model with a podcast API.
    ///
    /// - Parameter podcastAPI: The API service used to fetch podcast data
    init(podcastAPI: PodcastAPIProtocol) {
        self.podcastAPI = podcastAPI
    }

    /// Loads the list of podcasts.
    ///
    /// This method updates the loading state, clears any existing errors,
    /// and fetches the podcast list from the API. If the request fails,
    /// an error message is exposed for the UI to display.
    public func loadPodcastList() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }

        do {
            podcastList = try await podcastAPI.fetchPodcastList()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
