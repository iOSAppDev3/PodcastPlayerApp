//
//  PodcastAPI.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

protocol PodcastAPIProtocol {
    func fetchPodcastList() async throws -> [Podcast]
    func fetchPodcast(id: Int) async throws -> Podcast
    func fetchEpisodes(for podcastId: Int) async throws -> [Episode]
}

final class PodcastAPI: PodcastAPIProtocol {
    
    private let baseURL: String
    private let networkClient: NetworkClientProtocol
    private let decoder: JSONDecoder

    init(baseURL: String, networkClient: NetworkClientProtocol = NetworkClient(),
        decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.decoder = decoder
    }
    
    public func fetchPodcastList() async throws -> [Podcast] {
        let response: PodcastListResponse = try await request(path: "/v1/toplist")
        return response.results
    }

    func fetchPodcast(id: Int) async throws -> Podcast {
        let response: PodcastDetailResponse = try await request(path: "/v1/podcasts/\(id)")
        return response.podcast
    }

    func fetchEpisodes(for podcastId: Int) async throws -> [Episode] {
        let response: EpisodeListResponse = try await request(path: "/v1/podcasts/\(podcastId)/episodes")
        return response.results
    }

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
