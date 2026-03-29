//
//  PodcastMiniPlayerView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var playerViewModel: PodcastPlayerViewModel
    
    var miniPlayerIconName: String {
        switch playerViewModel.playerState {
            case .playing:
                return "pause.fill"
            default:
                return "play.fill"
        }
    }
    
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
                        if playerViewModel.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: miniPlayerIconName)
                        }
                    }
                    .disabled(playerViewModel.isLoading)
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
