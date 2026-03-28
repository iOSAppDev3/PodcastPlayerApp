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
                AsyncImage(url: URL(string: "https://hws.dev/paul2.jpg")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.blue.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sample Track")
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    Text("Artist Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
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
