//
//  EpisodeListView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct EpisodeListView : View {
    
    var body : some View {
        VStack(spacing: 10) {
            Group {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        PodcastDetailView()
                    }
                }
                
            }
        }
        .navigationTitle("Episodes")
    }
}

#Preview {
    EpisodeListView()
}
