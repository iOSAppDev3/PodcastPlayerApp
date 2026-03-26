//
//  ContentView.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import SwiftUI

struct PodcastGridView: View {
    let items = Array(1...10)
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(items, id: \.self) { item in
                    Text("Item \(item)")
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal, 12)
                }
            }.padding()
        }.navigationTitle("Podcasts")
    }
}

#Preview {
    NavigationStack {
        PodcastGridView()
    }
}
