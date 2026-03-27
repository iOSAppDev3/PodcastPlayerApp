//
//  Episodes.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

struct EpisodeListResponse: Decodable {
    let limit: Int?
    let offset: Int?
    let total: Int?
    let results: [Episode]
}

struct Episode: Decodable, Identifiable {
    let id: Int
    let description: String
    let duration: Int?
    let encoded: String?
    let episode: Int?
    let exclusive: Bool
    let mimeType: String?
    let podcastID: Int
    let published: TimeInterval?
    let season: Int?
    let slug: String
    let title: String
    let type: String
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case duration
        case encoded
        case episode
        case exclusive
        case mimeType = "mime_type"
        case podcastID = "podcast_id"
        case published
        case season
        case slug
        case title
        case type
        case url
    }
}

extension Episode {
    var durationText: String {
        guard let duration else { return "--:--" }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var publishedText: String {
        guard let published else { return "Unknown date" }
        let date = Date(timeIntervalSince1970: published)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var shortDescription: String {
        description
            .replacingOccurrences(of: "\n", with: " ")
    }
}
