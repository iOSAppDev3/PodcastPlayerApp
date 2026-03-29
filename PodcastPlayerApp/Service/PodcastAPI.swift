//
//  PodcastAPI.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

protocol PodcastAPIProtocol {
    /// Fetches the list of top podcasts.
    ///
    /// - Returns: An array of `Podcast` objects.
    /// - Throws: An error if the request fails, the response is invalid or decoding fails.
    func fetchPodcastList() async throws -> [Podcast]
    
    // Fetches the details for a specific podcast.
    ///
    /// - Parameter id: The unique identifier of the podcast.
    /// - Returns: A `Podcast` object containing the podcast details.
    /// - Throws: An error if the request fails, the response is invalid or decoding fails.
    func fetchPodcast(id: Int) async throws -> Podcast
    
    /// Fetches the episodes for a given podcast.
    ///
    /// - Parameter podcastId: The unique identifier of the podcast.
    /// - Returns: An array of `Episode` objects.
    /// - Throws: A PodcastAppError if the request fails, the response is invalid or decoding fails
    func fetchEpisodes(for podcastId: Int) async throws -> [Episode]
}

final class PodcastAPI: PodcastAPIProtocol {
    
    private let baseURL: String
    private let networkClient: NetworkClientProtocol
    private let decoder: JSONDecoder

    /// Creates a new `PodcastAPI` instance.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for the podcast API.
    ///   - networkClient: The network client used to execute requests. Defaults to `NetworkClient()`.
    ///   - decoder: The decoder used to parse JSON responses. Defaults to `JSONDecoder()`.
    init(baseURL: String, networkClient: NetworkClientProtocol = NetworkClient(),
        decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.decoder = decoder
    }
    
    /// Fetches the list of top podcasts.
    ///
    /// - Returns: An array of `Podcast` objects.
    /// - Throws: A PodcastAppError if the request fails, the response is invalid or decoding fails.
    public func fetchPodcastList() async throws -> [Podcast] {
        let response: PodcastListResponse = try await request(path: "/v1/toplist")
        return response.results
    }

    // Fetches the details for a specific podcast.
    ///
    /// - Parameter id: The unique identifier of the podcast.
    /// - Returns: A `Podcast` object containing the podcast details.
    /// - Throws: A PodcastAppError if the request fails, the response is invalid or decoding fails.
    func fetchPodcast(id: Int) async throws -> Podcast {
        let response: PodcastDetailResponse = try await request(path: "/v1/podcasts/\(id)")
        return response.podcast
    }

    /// Fetches the episodes for a given podcast.
    ///
    /// - Parameter podcastId: The unique identifier of the podcast.
    /// - Returns: An array of `Episode` objects.
    /// - Throws: A PodcastAppError if the request fails, the response is invalid or decoding fails
    func fetchEpisodes(for podcastId: Int) async throws -> [Episode] {
        let response: EpisodeListResponse = try await request(path: "/v1/podcasts/\(podcastId)/episodes")
        return response.results
    }

    // MARK: - Helper method
    
    /// Performs a network request and decodes the response into the requested type.
    ///
    /// This helper method constructs the full URL, performs the request,
    /// validates the HTTP response, and decodes the returned JSON payload.
    ///
    /// - Parameter path: The endpoint path to append to the base URL.
    /// - Returns: A decoded object of type `T`.
    /// - Throws:
    ///   - `PodcastAppError.invalidURL` if the URL is malformed.
    ///   - `PodcastAppError.invalidResponse` if the response is not an `HTTPURLResponse`.
    ///   - `PodcastAppError.badStatusCode` if the server responds with bad status code.
    ///   - `PodcastAppError.jsonError` if decoding fails.
    ///   - `PodcastAppError.unknown` for any unexpected error.
    private func request<T: Decodable>(path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw PodcastAppError.invalidURL
        }

        do {
            let (data, response) = try await networkClient.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PodcastAppError.invalidResponse
            }

            guard 200...299 ~= httpResponse.statusCode else {
                throw PodcastAppError.badStatusCode(httpResponse.statusCode)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw PodcastAppError.jsonError
            }
        } catch let error as PodcastAppError {
            throw error
        } catch {
            throw PodcastAppError.unknown(error)
        }
    }
}
