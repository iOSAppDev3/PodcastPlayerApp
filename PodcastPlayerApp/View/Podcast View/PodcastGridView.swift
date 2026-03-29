//
//  PodcastGridView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import SwiftUI

struct PodcastGridView : View {
    let podcast: Podcast
    
    var body: some View {
        VStack(spacing: 16) {
            PodcastArtworkView(imageURLString: podcast.image,title: podcast.title, size: 150)
                .padding(.top)
            Text(podcast.title)
                .font(.headline.bold())
                .foregroundStyle(.primary)
                .tint(.primary)
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
