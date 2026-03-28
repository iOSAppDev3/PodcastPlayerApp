//
//  PodcastContainerView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import SwiftUI

struct PodcastContainerView: View {
    @StateObject private var playerViewModel = PodcastPlayerViewModel()
    @StateObject private var podcastListViewModel: PodcastListViewModel
    private let podcastAPI: PodcastAPIProtocol
    @State private var showFullPlayer = false
    @Environment(\.colorScheme) private var colorScheme

    init(viewModel: PodcastListViewModel, podcastAPI: PodcastAPIProtocol) {
        _podcastListViewModel = StateObject(wrappedValue: viewModel)
        self.podcastAPI = podcastAPI
    }

    var body: some View {
        NavigationStack {
            PodcastListView(
                viewModel: podcastListViewModel,
                podcastAPI: podcastAPI
            )
        }
        .environmentObject(playerViewModel)
        .background(AppGradients.appBackground(for: colorScheme))
        .safeAreaInset(edge: .bottom) {
            if playerViewModel.currentEpisode != nil {
                MiniPlayerView(playerViewModel: playerViewModel)
                    .onTapGesture {
                        showFullPlayer = true
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
            }
        }
        .sheet(isPresented: $showFullPlayer) {
            PodcastPlayerView(playerViewModel: playerViewModel)
        }
    }
}
