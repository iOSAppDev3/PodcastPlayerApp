//
//  PodcastPlayerApp.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

@main
struct PodcastPlayerApp: App {
    private let podcastAPI = PodcastAPI(baseURL: AppConfig.baseURLString)
    
    var body: some Scene {
        WindowGroup {
            PodcastContainerView(viewModel: PodcastListViewModel(podcastAPI: podcastAPI), podcastAPI: podcastAPI)
        }
    }
}
