//
//  NetworkClient.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

protocol NetworkClientProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

final class NetworkClient: NetworkClientProtocol {
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: url)
    }
}
