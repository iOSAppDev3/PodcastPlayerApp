//
//  MockNetworkClient.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//

import Foundation
@testable import PodcastPlayerApp

final class MockNetworkClient: NetworkClientProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }

        guard let data = data,
              let response = response else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}
