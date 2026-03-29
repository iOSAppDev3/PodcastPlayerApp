//
//  PodcastAudioPlayerService.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//

import AVFoundation

protocol PodcastAudioPlayerServiceProtocol: AnyObject {
    var isPlaying: Bool { get }
    var currentTime: Double { get }
    var duration: Double { get }
    func loadAudio(from url: URL) async throws
    func play()
    func pause()
    func seek(to time: Double)
    func skip(seconds: Double)
    func addTimeObserver(_ onUpdate: @escaping (Double) -> Void)
    func removeTimeObserver()
}

final class PodcastAudioPlayerService: PodcastAudioPlayerServiceProtocol {
    private var player: AVPlayer?
    private var timeObserver: Any?

    private(set) var isPlaying: Bool = false
    private(set) var currentTime: Double = 0
    private(set) var duration: Double = 0

    deinit {
        removeTimeObserver()
    }

    func loadAudio(from url: URL) async throws {
        removeTimeObserver()

        let player = AVPlayer(url: url)
        self.player = player

        let asset = AVURLAsset(url: url)

        do {
            let loadedDuration = try await asset.load(.duration)
            duration = CMTimeGetSeconds(loadedDuration)
        } catch {
            throw PodcastAppError.unknown(error)
        }
    }

    func play() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func seek(to time: Double) {
        guard let player else { return }
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime)
        currentTime = time
    }

    func skip(seconds: Double) {
        guard let player else { return }

        let current = CMTimeGetSeconds(player.currentTime())
        let newTime = max(0, min(current + seconds, duration))
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
    }

    func addTimeObserver(_ onUpdate: @escaping (Double) -> Void) {
        guard let player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.currentTime = seconds
            onUpdate(seconds)
        }
    }

    func removeTimeObserver() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}
