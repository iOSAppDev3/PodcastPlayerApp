//
//  PodcastPlayerView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import SwiftUI
import AVFoundation

struct PodcastPlayerView: View {
    @ObservedObject var playerViewModel: PodcastPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            AppGradients.appBackground(for: colorScheme)

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.top)

                AsyncImage(url: URL(string: "https://hws.dev/paul2.jpg")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.white.opacity(0.15)
                }
                .frame(width: 350, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(spacing: 8) {
                    Text("Sample Track")
                        .font(.title.bold())
                        .foregroundColor(.primary)

                    Text("Artist Name")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { playerViewModel.currentTime },
                            set: { playerViewModel.seek(to: $0) }
                        ),
                        in: 0...max(playerViewModel.duration, 1)
                    )
                    .tint(.white)

                    HStack {
                        Text(playerViewModel.formatTime(playerViewModel.currentTime))
                        Spacer()
                        Text(playerViewModel.formatTime(playerViewModel.duration))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                HStack(spacing: 40) {
                    Button {
                        playerViewModel.skip(seconds: -10)
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.primary)
                    }

                    Button {
                        playerViewModel.togglePlayPause()
                    } label: {
                        Image(systemName: playerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.primary)
                    }

                    Button {
                        playerViewModel.skip(seconds: 10)
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding()
        }
    }
}
