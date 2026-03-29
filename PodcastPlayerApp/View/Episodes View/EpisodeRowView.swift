//
//  EpisodeRowView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct EpisodeRowView: View {
    let episode: Episode
    let playerState: PlayerState
    let onPlayTapped: () -> Void
    
    private var buttonIcon: String {
        switch playerState {
        case .playing(let id) where id == episode.id:
            return "pause.fill"
        case .paused(let id) where id == episode.id:
            return "play.fill"
        default:
            return "play.fill"
        }
    }
    
    private var isLoading: Bool {
        if case .loading(let id) = playerState {
            return id == episode.id
        }
        return false
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
            
            Text(episode.description)
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
                    ZStack {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 36, height: 36)
                        Image(systemName: buttonIcon)
                            .foregroundStyle(Color(.systemBackground))
                    }
                }
            }
            Divider()
                .background(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
