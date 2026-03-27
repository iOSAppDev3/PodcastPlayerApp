//
//  EpisodeListView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct EpisodeListView : View {
    @StateObject private var viewModel: EpisodeListViewModel
    @State private var selectedEpisode: Episode?
    @State private var showPlayer = false
    
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
            .background(Color(.black))
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading Episodes...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Unable to load episodes",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PodcastDetailView(podcast: viewModel.podcast)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.black,
                                    Color.purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 6)
                        LazyVStack(spacing: 12) {
                            Text("Episodes")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ForEach(viewModel.episodes) { episode in
                            Button {
                                selectedEpisode = episode
                                showPlayer = true
                            } label: {
                                EpisodeRowView(episode: episode)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
        }
    }
}
