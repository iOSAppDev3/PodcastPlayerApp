//
//  AppUtils.swift
//  MediaPlayer
//
//  Created by Bakkiya Murugan on 28/03/2026.
//


import SwiftUI

enum AppGradients {
    static func appBackground(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [.purple, .indigo, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    .purple.opacity(0.4),
                    .indigo.opacity(0.2),
                    .white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
