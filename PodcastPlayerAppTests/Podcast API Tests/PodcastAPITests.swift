//
//  PodcastAPITests.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//


import XCTest
@testable import PodcastPlayerApp

final class PodcastAPITests: XCTestCase {
    
    private var sut: PodcastAPI!
    private var mockNetworkClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = PodcastAPI(
            baseURL: "https://example.com",
            networkClient: mockNetworkClient
        )
    }

    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    private func loadJSON(named fileName: String) throws -> Data {
        // Locate file inside test bundle
        let bundle = Bundle(for: type(of: self))
        
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("Missing file: \(fileName).json")
            throw URLError(.fileDoesNotExist)
        }
        
        return try Data(contentsOf: url)
    }
    
    private func makeHTTPResponse(urlString: String, statusCode: Int) -> HTTPURLResponse {
        // Convenience helper to reduce repetition when mocking HTTP responses
        HTTPURLResponse(
            url: URL(string: urlString)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    private func makeInvalidResponse(urlString: String) -> URLResponse {
        URLResponse(
            url: URL(string: urlString)!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }

    private var invalidJSON: Data {
        """
        {
          "wrong_key": []
        }
        """.data(using: .utf8)!
    }

    // MARK: - Podcast List Tests
    /// Test for fetching Podlist List successful
    func testFetchPodcastListSuccess() async throws {
       
        let json = try loadJSON(named: "PodcastListResponse")
        // Mock a successful API response
        mockNetworkClient.data = json
        mockNetworkClient.response = HTTPURLResponse(
            url: URL(string: "https://example.com/v1/toplist")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let podcasts = try await sut.fetchPodcastList()
        
        // Validate total count
        XCTAssertEqual(podcasts.count, 40)
        
        // Validate first podcast mapping
        XCTAssertEqual(podcasts[0].id, 129587)
        XCTAssertEqual(podcasts[0].title, "Dateline NBC")
        
        // Validate second podcast mapping
        XCTAssertEqual(podcasts[1].id, 41593)
        XCTAssertEqual(podcasts[1].title, "Crime Junkie")
    }
    
    /// Tests for fetching podcast list failed with 404 error
    func testFetchPodcastListThrowsBadStatusCode() async {
        // GIVEN: a non-success HTTP status code
        mockNetworkClient.data = Data()
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/toplist",
            statusCode: 404
        )

        // API should throw the matching bad status code error
        do {
            _ = try await sut.fetchPodcastList()
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .badStatusCode(let code):
                XCTAssertEqual(code, 404)
            default:
                XCTFail("Expected badStatusCode, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Tests for fetching podcast list failed with json parsing error
    func testFetchPodcastListThrowsJSONError() async {
        mockNetworkClient.data = invalidJSON
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/toplist",
            statusCode: 200
        )

        do {
            _ = try await sut.fetchPodcastList()
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .jsonError:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected jsonError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Tests for fetching podcast list failed with invalid response
    func testFetchPodcastListThrowsInvalidResponse() async {
        // GIVEN: a response that is not an HTTPURLResponse
        mockNetworkClient.data = Data()
        mockNetworkClient.response = URLResponse(
            url: URL(string: "https://example.com/v1/toplist")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        do {
            _ = try await sut.fetchPodcastList()
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .invalidResponse:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Tests for fetching podcast list failed with invalid url
    func testFetchPodcastListThrowsInvalidURL() async {
         // Mocking invalid url
        sut = PodcastAPI(
            baseURL: "http://%",
            networkClient: mockNetworkClient
        )
        do {
            _ = try await sut.fetchPodcastList()
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .invalidURL:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalidURL \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Tests for fetching podcast list failed with unknown error
    func testFetchPodcastListThrowsUnknownError() async {
        mockNetworkClient.error = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.fetchPodcastList()
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .unknown(let underlyingError as URLError):
                XCTAssertEqual(underlyingError.code, .notConnectedToInternet)
            default:
                XCTFail("Expected unknown error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    //MARK: - Podcast ID Tests
    
    /// Test for fetching Podlist for its ID successful with status code
    func testFetchPodcastByIDSuccess() async throws {
       
        let json = try loadJSON(named: "PodcastDetailResponse")
        // Mock a successful API response
        mockNetworkClient.data = json
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/podcasts/1202166",
            statusCode: 200
        )

        let podcast = try await sut.fetchPodcast(id: 1202166)
        
        XCTAssertEqual(podcast.id, 1202166)
        XCTAssertEqual(podcast.title, "The Rest Is Politics: US")
    }
    
    /// Test for fetching Podlist for its ID failed with status code
    func testFetchPodcastThrowsBadStatusCode() async {
        mockNetworkClient.data = Data()
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/podcasts/1202166",
            statusCode: 500
        )

        do {
            _ = try await sut.fetchPodcast(id: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .badStatusCode(let code):
                XCTAssertEqual(code, 500)
            default:
                XCTFail("Expected badStatusCode, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPodcastThrowsJSONErrorWhenDecodingFails() async {
        mockNetworkClient.data = invalidJSON
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/podcasts/1202166",
            statusCode: 200
        )

        do {
            _ = try await sut.fetchPodcast(id: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            guard case .jsonError = error else {
                return XCTFail("Expected jsonError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPodcastThrowsInvalidResponse() async {
        mockNetworkClient.data = Data()
        mockNetworkClient.response = makeInvalidResponse(
            urlString: "https://example.com/v1/podcasts/1202166"
        )

        do {
            _ = try await sut.fetchPodcast(id: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            guard case .invalidResponse = error else {
                return XCTFail("Expected invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPodcastThrowsInvalidURL() async {
        sut = PodcastAPI(
            baseURL: "http://%",
            networkClient: mockNetworkClient
        )

        do {
            _ = try await sut.fetchPodcast(id: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .invalidURL:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalidURL, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }


    func testFetchPodcastThrowsUnknownError() async {
        mockNetworkClient.error = URLError(.timedOut)

        do {
            _ = try await sut.fetchPodcast(id: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            guard case .unknown(let underlyingError as URLError) = error else {
                return XCTFail("Expected unknown error, got \(error)")
            }
            XCTAssertEqual(underlyingError.code, .timedOut)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }


    //MARK: - Episode List Tests

    /// Tests to fetch Episode sucess for its podcast id
    func testFetchEpisodesForPodcastIDSuccess() async throws {
        
        let json = try loadJSON(named: "EpisodeListResponse")
        // Mock a successful API response
        mockNetworkClient.data = json
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/podcasts/1202166/episodes",
            statusCode: 200
        )

        let episodes = try await sut.fetchEpisodes(for: 1202166)

        XCTAssertEqual(episodes.count, 20)

        XCTAssertEqual(episodes[0].id, 766846131)
        XCTAssertEqual(episodes[0].title, "Trump Is Trapped in the Iran War")

        XCTAssertEqual(episodes[1].id, 765539257)
        XCTAssertEqual(episodes[1].title, "Trump Backs Down on Iran Threats - What Next?")
    }
    
    /// Tests to fetch Episode failed for its podcast id
    func testFetchEpisodesThrowsBadStatusCode() async {

        mockNetworkClient.data = Data()
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/podcasts/1202166/episodes",
            statusCode: 403
        )

        do {
            _ = try await sut.fetchEpisodes(for: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .badStatusCode(let code):
                XCTAssertEqual(code, 403)
            default:
                XCTFail("Expected badStatusCode, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchEpisodesThrowsJSONErrorWhenDecodingFails() async {
        mockNetworkClient.data = invalidJSON
        mockNetworkClient.response = makeHTTPResponse(
            urlString: "https://example.com/v1/podcasts/1202166/episodes",
            statusCode: 200
        )

        do {
            _ = try await sut.fetchEpisodes(for: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            guard case .jsonError = error else {
                return XCTFail("Expected jsonError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchEpisodesThrowsInvalidResponse() async {
        mockNetworkClient.data = Data()
        mockNetworkClient.response = makeInvalidResponse(
            urlString: "https://example.com/v1/podcasts/1202166/episodes"
        )

        do {
            _ = try await sut.fetchEpisodes(for: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            guard case .invalidResponse = error else {
                return XCTFail("Expected invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchEpisodesThrowsInvalidURL() async {
        sut = PodcastAPI(
            baseURL: "http://%",
            networkClient: mockNetworkClient
        )

        do {
            _ = try await sut.fetchEpisodes(for: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            switch error {
            case .invalidURL:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalidURL, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchEpisodesThrowsUnknownError() async {
        mockNetworkClient.error = URLError(.cannotFindHost)

        do {
            _ = try await sut.fetchEpisodes(for: 1202166)
            XCTFail("Expected error to be thrown")
        } catch let error as PodcastAppError {
            guard case .unknown(let underlyingError as URLError) = error else {
                return XCTFail("Expected unknown error, got \(error)")
            }
            XCTAssertEqual(underlyingError.code, .cannotFindHost)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
