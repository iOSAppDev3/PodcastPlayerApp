//
//  PodcastMiniPlayerView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var playerViewModel: PodcastPlayerViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                PodcastArtworkView(imageURLString: playerViewModel.currentPodcast?.image, title: "", size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(playerViewModel.currentEpisode!.title)
                        .font(.subheadline.bold())
                        .lineLimit(2)

                    Text(playerViewModel.currentPodcast?.title ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        playerViewModel.skip(seconds: -10)
                    } label: {
                        Image(systemName: "gobackward.10")
                    }

                    Button {
                        playerViewModel.togglePlayPause()
                    } label: {
                        Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                    }

                    Button {
                        playerViewModel.skip(seconds: 10)
                    } label: {
                        Image(systemName: "goforward.10")
                    }
                }
                .font(.title3)
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}
