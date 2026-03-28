//
//  PodcastPlayerApp.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

@main
struct PodcastPlayerApp: App {
    private let podcastAPI = PodcastAPI(baseURL: "https://the-podcasts.fly.dev")
    
    var body: some Scene {
        WindowGroup {
            PodcastContainerView(viewModel: PodcastListViewModel(podcastAPI: podcastAPI), podcastAPI: podcastAPI)
        }
    }
}
