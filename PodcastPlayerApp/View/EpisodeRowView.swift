//
//  EpisodeRowView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct EpisodeRowView: View {
    let episode: Episode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(episode.publishedText, systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.white)
            Text(episode.title)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)

            Text(episode.shortDescription)
                .font(.footnote)
                .foregroundStyle(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            Label(episode.durationText, systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.purple)
            Divider()
                .background(.gray)
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.black))
    }
}
