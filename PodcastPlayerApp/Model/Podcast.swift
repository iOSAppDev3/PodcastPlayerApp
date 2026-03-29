//
//  Podcast.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

///Model representing a list of Podcasts
struct PodcastListResponse: Decodable {
    let limit: Int?
    let offset: Int?
    let total: Int?
    let results: [Podcast]
}

/// Model representing a podcast detail response
struct PodcastDetailResponse: Decodable {
    let podcast: Podcast
}

/// Model representing a podcast.
struct Podcast: Decodable, Identifiable {
    let id: Int
    let author: String
    let categoryIDs: [Int]
    let description: String
    let image: String?
    let languageISO: String
    let link: String?
    let original: Bool
    let popularity: Double?
    let rss: String
    let seasonal: Bool
    let slug: String
    let title: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case categoryIDs = "category_id"
        case description
        case image
        case languageISO = "language_iso"
        case link
        case original
        case popularity
        case rss
        case seasonal
        case slug
        case title
        case type
    }
}
