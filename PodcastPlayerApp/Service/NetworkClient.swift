//
//  NetworkClient.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

protocol NetworkClientProtocol {
    
    /// Fetches data from the given URL.
    ///
    /// - Parameter url: The endpoint URL.
    /// - Returns: A tuple containing the response `Data` and `URLResponse`.
    /// - Throws: An error if the request fails.
    func data(from url: URL) async throws -> (Data, URLResponse)
}

final class NetworkClient: NetworkClientProtocol {
    
    /// Performs a network request using `URLSession.shared`.
    ///
    /// - Parameter url: The endpoint URL.
    /// - Returns: A tuple containing the response `Data` and `URLResponse`.
    /// - Throws: An error if the request fails.
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: url)
    }
}
