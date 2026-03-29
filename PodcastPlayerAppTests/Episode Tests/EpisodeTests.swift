//
//  EpisodeTests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
@testable import PodcastPlayerApp

final class EpisodeTests: XCTestCase {
    
    private func makeEpisode(
        id: Int = 1,
        description: String = "Test Description",
        duration: Int? = 60,
        encoded: String? = nil,
        episode: Int? = nil,
        exclusive: Bool = false,
        mimeType: String? = nil,
        podcastID: Int = 1,
        published: TimeInterval? = 0,
        season: Int? = nil,
        slug: String = "test-slug",
        title: String = "Test Title",
        type: String = "full",
        url: String? = nil
    ) -> Episode {
        Episode(
            id: id,
            description: description,
            duration: duration,
            encoded: encoded,
            episode: episode,
            exclusive: exclusive,
            mimeType: mimeType,
            podcastID: podcastID,
            published: published,
            season: season,
            slug: slug,
            title: title,
            type: type,
            url: url
        )
    }
    
    // MARK: - durationText
    
    func test_durationText_returnsFormattedDuration() {
        let episode = makeEpisode(duration: 125)
        XCTAssertEqual(episode.durationText, "2:05")
    }
    
    func test_durationText_returnsPlaceholder_whenDurationIsNil() {
        let episode = makeEpisode(duration: nil)
        XCTAssertEqual(episode.durationText, "--:--")
    }
    
    func test_durationText_handlesZero() {
        let episode = makeEpisode(duration: 0)
        XCTAssertEqual(episode.durationText, "0:00")
    }
    
    // MARK: - publishedText
    
    func test_publishedText_returnsUnknownDate_whenPublishedIsNil() {
        let episode = makeEpisode(published: nil)
        XCTAssertEqual(episode.publishedText, "Unknown date")
    }
    
    func test_publishedText_returnsFormattedDate_whenPublishedExists() {
        let publishedTime: TimeInterval = 1711843200 // 31 Mar 2024 00:00:00 UTC
        let episode = makeEpisode(published: publishedTime)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let expected = formatter.string(from: Date(timeIntervalSince1970: publishedTime))
        
        XCTAssertEqual(episode.publishedText, expected)
    }
    
    // MARK: - Decoding
    
    func test_decodesEpisodeCorrectly() throws {
        let json = """
        {
            "id": 101,
            "description": "Episode description",
            "duration": 3600,
            "encoded": "abc123",
            "episode": 5,
            "exclusive": true,
            "mime_type": "audio/mpeg",
            "podcast_id": 999,
            "published": 1711843200,
            "season": 2,
            "slug": "episode-101",
            "title": "Great Episode",
            "type": "full",
            "url": "https://example.com/audio.mp3"
        }
        """.data(using: .utf8)!
        
        let episode = try JSONDecoder().decode(Episode.self, from: json)
        
        XCTAssertEqual(episode.id, 101)
        XCTAssertEqual(episode.description, "Episode description")
        XCTAssertEqual(episode.duration, 3600)
        XCTAssertEqual(episode.encoded, "abc123")
        XCTAssertEqual(episode.episode, 5)
        XCTAssertEqual(episode.exclusive, true)
        XCTAssertEqual(episode.mimeType, "audio/mpeg")
        XCTAssertEqual(episode.podcastID, 999)
        XCTAssertEqual(episode.published, 1711843200)
        XCTAssertEqual(episode.season, 2)
        XCTAssertEqual(episode.slug, "episode-101")
        XCTAssertEqual(episode.title, "Great Episode")
        XCTAssertEqual(episode.type, "full")
        XCTAssertEqual(episode.url, "https://example.com/audio.mp3")
    }
    
    func test_decodesEpisodeCorrectly_whenOptionalFieldsAreMissing() throws {
        let json = """
        {
            "id": 202,
            "description": "Minimal episode",
            "exclusive": false,
            "podcast_id": 123,
            "slug": "minimal-episode",
            "title": "Minimal",
            "type": "trailer"
        }
        """.data(using: .utf8)!
        
        let episode = try JSONDecoder().decode(Episode.self, from: json)
        
        XCTAssertEqual(episode.id, 202)
        XCTAssertEqual(episode.description, "Minimal episode")
        XCTAssertNil(episode.duration)
        XCTAssertNil(episode.encoded)
        XCTAssertNil(episode.episode)
        XCTAssertEqual(episode.exclusive, false)
        XCTAssertNil(episode.mimeType)
        XCTAssertEqual(episode.podcastID, 123)
        XCTAssertNil(episode.published)
        XCTAssertNil(episode.season)
        XCTAssertEqual(episode.slug, "minimal-episode")
        XCTAssertEqual(episode.title, "Minimal")
        XCTAssertEqual(episode.type, "trailer")
        XCTAssertNil(episode.url)
    }
}
