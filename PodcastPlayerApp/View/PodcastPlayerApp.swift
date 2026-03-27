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
    
    init() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            PodcastListView(viewModel: PodcastListViewModel(podcastAPI: podcastAPI), podcastAPI: podcastAPI)
        }
    }
}
