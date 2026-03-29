//
//  PodcastListView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct PodcastListView: View {
    @StateObject private var viewModel: PodcastListViewModel
    private let podcastAPI: PodcastAPIProtocol
    @Environment(\.colorScheme) private var colorScheme
    @State private var showFullPlayer = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(viewModel: PodcastListViewModel, podcastAPI: PodcastAPIProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.podcastAPI = podcastAPI
    }
    
    var body: some View {
        ZStack {
            AppGradients.appBackground(for: colorScheme)
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading Podcasts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.primary)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "wifi.exclamationmark",
                        description: Text(errorMessage)
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.podcastList) { podcast in
                            NavigationLink {
                                EpisodeListView(
                                    viewModel: EpisodeListViewModel(
                                        podcast: podcast,
                                        podcastAPI: podcastAPI
                                    )
                                )
                            } label: {
                                PodcastGridView(podcast: podcast)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Podcasts")
        .task {
            if viewModel.podcastList.isEmpty {
                await viewModel.loadPodcastList()
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
