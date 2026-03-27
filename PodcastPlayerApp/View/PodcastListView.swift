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

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(viewModel: PodcastListViewModel, podcastAPI: PodcastAPIProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.podcastAPI = podcastAPI
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading Podcasts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .navigationTitle("Podcasts")
            .task {
                if viewModel.podcastList.isEmpty {
                    await viewModel.loadPodcastList()
                }
                
            }
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
            .shadow(color: Color.purple.opacity(0.15), radius: 10, x: 0, y: 6)
            
        }
    }
}

struct PodcastGridView : View {
    let podcast: Podcast
    
    var body: some View {
        VStack(spacing: 16) {
            PodcastArtworkView(title: podcast.title, size: 155)
                .padding(.top)
            Text(podcast.title)
                .font(.headline.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 44)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 200)
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}   
