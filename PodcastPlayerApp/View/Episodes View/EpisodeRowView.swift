//
//  EpisodeRowView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct EpisodeRowView: View {
    let episode: Episode
    let isCurrentEpisode: Bool
    let isPlaying: Bool
    let onPlayTapped: () -> Void
    
    private var buttonIcon: String {
         if isCurrentEpisode {
             return isPlaying ? "pause.fill" : "play.fill"
         } else {
             return "play.fill"
         }
     }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Label(episode.publishedText, systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(episode.title)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
            
            Text(episode.shortDescription)
                .font(.footnote)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            HStack(alignment: .center) {
                Label(episode.durationText, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onPlayTapped) {
                    Image(systemName: buttonIcon)
                        .foregroundStyle(Color(.systemBackground))
                        .padding(8)
                        .background(Color.primary)
                        .clipShape(Circle())
                }
            }
            Divider()
                .background(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
