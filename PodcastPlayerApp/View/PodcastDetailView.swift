//
//  PodcastDetailView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct PodcastDetailView: View {
    let podcast: Podcast
    
    var body: some View {
        VStack(spacing: 16) {
            PodcastArtworkView(title: podcast.title, size: 120)
            VStack(spacing: 6) {
                Text(podcast.title)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(podcast.author)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                Text(podcast.description)
                    .font(.footnote)
                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
        .padding(.horizontal)
    }
}


