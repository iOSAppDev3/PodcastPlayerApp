//
//  PodcastAppError.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 26/03/2026.
//

import Foundation

/// Represents possible errors that can occur during network operations.
enum PodcastAppError: LocalizedError {
    
    /// The URL provided for the request is invalid.
    case invalidURL
    
    /// The response from server is not valid or cannot be handled.
    case invalidResponse
    
    /// The server returned a non-success HTTP status code.
    case badStatusCode(Int)
    
    /// Failed to decode or parse the JSON response.
    case jsonError
    
    /// The request completed successfully but returned no data or results.
    case emptyResults
    
    /// An unknown error occurred.
    case unknown(Error)

    /// A human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .badStatusCode(let code):
            return "Server error \(code)."
        case .jsonError:
            return "Error parsing JSON."
        case .emptyResults:
            return "No results found."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
