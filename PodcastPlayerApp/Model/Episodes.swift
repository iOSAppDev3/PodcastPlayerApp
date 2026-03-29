//
//  Episodes.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

///Model representing a list of episodes
struct EpisodeListResponse: Decodable {
    let limit: Int?
    let offset: Int?
    let total: Int?
    let results: [Episode]
}

/// Model representing a podcast episode.
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
    
    /// A formatted string representing the episode duration (mm:ss).
    ///
    /// Returns "--:--" if duration is unavailable.
    var durationText: String {
        guard let duration else { return "--:--" }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// A human-readable string representing the published date.
    ///
    /// Returns "Unknown date" if the publish date is unavailable.
    var publishedText: String {
        guard let published else { return "Unknown date" }
        let date = Date(timeIntervalSince1970: published)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
