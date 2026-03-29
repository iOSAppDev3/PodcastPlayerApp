//
//  PodcastArtworkView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 27/03/2026.
//

import SwiftUI
import Kingfisher

struct PodcastArtworkView: View {
    let imageURLString: String?
    let title: String
    let size: CGFloat

    var body: some View {
        ZStack {
            if let url = URL(string: AppConfig.baseURLString + "/v1/images/" + (imageURLString ?? "")) {
                KFImage.url(url)
                    .placeholder {
                        placeholder
                    }
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: size, height: size))
                    )
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage()
                    .fade(duration: 0.2)
                    .cancelOnDisappear(true)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
        )
    }

    private var placeholder: some View {
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
    }
}
