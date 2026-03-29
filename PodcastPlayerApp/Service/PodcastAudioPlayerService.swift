//
//  PodcastAudioPlayerService.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 29/03/2026.
//

import AVFoundation

protocol PodcastAudioPlayerServiceProtocol: AnyObject {
 
    /// Indicates whether audio is currently playing.
    var isPlaying: Bool { get }
    
    /// The current playback time in seconds.
    var currentTime: Double { get }
    
    /// The total duration of the loaded audio in seconds.
    var duration: Double { get }
    
    /// Loads audio from a given URL.
    ///
    /// - Parameter url: The URL of the audio file.
    /// - Throws: An error if the asset fails to load.
    func loadAudio(from url: URL) async throws
    
    /// Starts or resumes playback.
    func play()
    
    /// Pauses playback.
    func pause()
    
    /// Seeks to a specific time in the audio.
    ///
    /// - Parameter time: The target time in seconds.
    func seek(to time: Double)
    
    /// Skips forward or backward by a given number of seconds.
    ///
    /// - Parameter seconds: Positive to skip forward, negative to skip backward.
    func skip(seconds: Double)
    
    /// Adds a periodic time observer for playback updates.
    ///
    /// - Parameter onUpdate: Closure called with the current playback time in seconds.
    func addTimeObserver(_ onUpdate: @escaping (Double) -> Void)
    
    /// Removes the active time observer.
    func removeTimeObserver()
}

final class PodcastAudioPlayerService: PodcastAudioPlayerServiceProtocol {
    
    /// AVPlayer instance.
    private var player: AVPlayer?
    
    /// Token for the periodic time observer.
    private var timeObserver: Any?

    /// Indicates whether audio is currently playing.
    private(set) var isPlaying: Bool = false
    
    /// The current playback time in seconds.
    private(set) var currentTime: Double = 0
    
    /// The total duration of the loaded audio in seconds.
    private(set) var duration: Double = 0

    deinit {
        removeTimeObserver()
    }

    /// Loads  an audio file for playback.
    ///
    /// This resets any existing player and observers, creates a new `AVPlayer`,
    /// and asynchronously loads the asset duration.
    ///
    /// - Parameter url: The URL of the audio file.
    /// - Throws: `PodcastAppError.unknown` if the duration fails to load.
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

    /// Starts or resumes playback.
    func play() {
        player?.play()
        isPlaying = true
    }

    /// Pauses playback.
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    /// Seeks to a specific time in the audio.
    ///
    /// - Parameter time: The target time in seconds.
    func seek(to time: Double) {
        guard let player else { return }
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime)
        currentTime = time
    }

    /// Skips forward or backward by a given number of seconds.
    ///
    /// Ensures the new time stays within valid bounds (0...duration).
    ///
    /// - Parameter seconds: Positive to skip forward, negative to skip backward.
    func skip(seconds: Double) {
        guard let player else { return }

        let current = CMTimeGetSeconds(player.currentTime())
        let newTime = max(0, min(current + seconds, duration))
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
    }

    /// Adds a periodic observer to track playback time. The observer fires every second on the main queue.
    ///
    /// - Parameter onUpdate: Closure called with updated playback time in seconds.
    func addTimeObserver(_ onUpdate: @escaping (Double) -> Void) {
        guard let player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.currentTime = seconds
            onUpdate(seconds)
        }
    }

    /// Removes the current time observer if it exists.
    func removeTimeObserver() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}
