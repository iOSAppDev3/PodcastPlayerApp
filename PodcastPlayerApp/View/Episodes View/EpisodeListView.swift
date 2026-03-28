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

    init(viewModel: EpisodeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(viewModel.podcast.title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                guard viewModel.episodes.isEmpty else { return }
                await viewModel.loadEpisodes()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading Episodes...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.primary)

        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Unable to load episodes",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )

        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PodcastDetailView(
                        podcast: viewModel.podcast,
                        onPlayTapped: {
                            playerViewModel.play(episode: viewModel.episodes.last!)
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Episodes")
                            .font(.title.bold())
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.episodes) { episode in
                                EpisodeRowView(
                                    episode: episode,
                                    onPlayTapped: {
                                        playerViewModel.play(episode: episode)
                                    }
                                )
                            }
                        }
                    }
                    .padding(20)
                }
                .padding(.bottom, 100)
            }
        }
    }
}
