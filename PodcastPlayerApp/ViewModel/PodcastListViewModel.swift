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
    
    private let podcastAPI: PodcastAPIProtocol

    init(podcastAPI: PodcastAPIProtocol) {
        self.podcastAPI = podcastAPI
    }

    public func loadPodcastList() async {
        isLoading = true
        errorMessage = nil

        do {
            podcastList = try await podcastAPI.fetchPodcastList()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
