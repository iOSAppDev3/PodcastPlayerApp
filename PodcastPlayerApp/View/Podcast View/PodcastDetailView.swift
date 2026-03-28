//
//  PodcastDetailView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct PodcastDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    let podcast: Podcast
    let onPlayTapped: () -> Void
    
    var body: some View {
        ZStack {
            AppGradients.appBackground(for: colorScheme)
            VStack(spacing: 16) {
                PodcastArtworkView(title: podcast.title, size: 120)
                VStack(spacing: 6) {
                    Text(podcast.title)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(podcast.author)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    
                    Button(action: onPlayTapped) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Latest Episode")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    Text(podcast.description)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
            .padding(.horizontal)
        }
    }
}


