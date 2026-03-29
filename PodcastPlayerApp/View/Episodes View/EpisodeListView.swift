//
//  EpisodeListView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct EpisodeListView: View {
    @StateObject private var viewModel: EpisodeListViewModel
    @EnvironmentObject private var playerViewModel: PodcastPlayerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: EpisodeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                loadedView
            }
        }
        .navigationTitle(viewModel.podcast.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primary)
                        .tint(.primary)
                }
            }
        }
        .task {
            guard viewModel.episodes.isEmpty else { return }
            await viewModel.loadEpisodes()
        }
        .padding(.bottom, 20)
    }
   
    /// Loading UI State
    private var loadingView: some View {
        ProgressView("Loading Episodes...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.primary)
    }

    /// Error UI State
    private func errorView(message: String) -> some View {
        ContentUnavailableView(
            "Unable to load episodes",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }

    /// Main content view when data is loaded.
    private var loadedView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                podcastHeaderView
                episodesSectionView
            }
        }
    }

    /// Displays podcast details and a play button for the latest episode.
    private var podcastHeaderView: some View {
        PodcastDetailView(
            podcast: viewModel.podcast,
            isCurrentEpisode: playerViewModel.currentEpisode?.id == viewModel.episodes.last?.id,
            isPlaying: playerViewModel.isPlaying,
            onPlayTapped: handlePodcastPlayTapped
        )
    }
    
    /// Handles tapping play on the podcast header (plays latest episode).
    private func handlePodcastPlayTapped() {
        guard let episode = viewModel.episodes.last else { return }
        Task {
            await playerViewModel.play(
                episode: episode,
                podcast: viewModel.podcast
            )
        }
    }

    /// Displays the list of episodes.
    private var episodesSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Episodes")
                .font(.title.bold())
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.episodes) { episode in
                    EpisodeRowView(
                        episode: episode,
                        playerState: playerViewModel.playerState,
                        onPlayTapped: {
                            Task {
                                await playerViewModel.play(episode: episode, podcast: viewModel.podcast)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
    }
}
