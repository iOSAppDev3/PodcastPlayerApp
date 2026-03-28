//
//  PodcastArtworkView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 27/03/2026.
//

import SwiftUI

struct PodcastArtworkView: View {
    let title: String
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "mic.fill")
                .font(.system(size: size * 0.28))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
    }
}
