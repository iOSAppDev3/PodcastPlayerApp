//
//  MockPodcastAudioPlayer.swift
//  PodcastPlayerAppTests
//
//  Created by Bakkiya Murugan on 29/03/2026.
//

import Foundation
@testable import PodcastPlayerApp

import Foundation
@testable import PodcastPlayerApp

final class MockPodcastAudioPlayerService: PodcastAudioPlayerServiceProtocol {
    var isPlaying: Bool = false
    var currentTime: Double = 0
    var duration: Double = 120

    var loadAudioCalled = false
    var playCalled = false
    var pauseCalled = false
    var seekCalled = false
    var skipCalled = false
    var removeTimeObserverCalled = false

    var loadedURL: URL?
    var seekedTime: Double?
    var skippedSeconds: Double?

    var loadAudioError: Error?
    var timeObserver: ((Double) -> Void)?

    func loadAudio(from url: URL) async throws {
        loadAudioCalled = true
        loadedURL = url

        if let loadAudioError {
            throw loadAudioError
        }
    }

    func play() {
        playCalled = true
        isPlaying = true
    }

    func pause() {
        pauseCalled = true
        isPlaying = false
    }

    func seek(to time: Double) {
        seekCalled = true
        seekedTime = time
        currentTime = time
    }

    func skip(seconds: Double) {
        skipCalled = true
        skippedSeconds = seconds
    }

    func addTimeObserver(_ onUpdate: @escaping (Double) -> Void) {
        timeObserver = onUpdate
    }

    func removeTimeObserver() {
        removeTimeObserverCalled = true
    }
}
