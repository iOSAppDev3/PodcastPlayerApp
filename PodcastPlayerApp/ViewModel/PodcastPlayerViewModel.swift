//
//  PodcastPlayerViewModel.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import AVFoundation

final class PodcastPlayerViewModel: ObservableObject {
    /// Current playing episode
    @Published var currentEpisode: Episode?
    /// Current playing podcast
    @Published var currentPodcast: Podcast?
    /// Play/pause button state
    @Published var isPlaying = false
    /// Progress bar position
    @Published var currentTime: Double = 0
    /// Total length of the audio
    @Published var duration: Double = 0
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    /// Audio player
    private var player: AVPlayer?
    /// Listener that tracks playback progress
    private var timeObserver: Any?
        
    deinit {
        removeTimeObserver()
    }
    
    /// Function to check current episode
    func isCurrentEpisode(_ episode: Episode) -> Bool {
        currentEpisode?.id == episode.id
    }
    
    /// Function to play an epsiode
    @MainActor
    func play(episode: Episode, podcast: Podcast) async throws {
        currentPodcast = podcast
        currentEpisode = episode

        do {
            try await loadAudio(for: episode)
            player?.play()
            isPlaying = true
            errorMessage = nil
            showErrorAlert = false
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            isPlaying = false
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
      }

    func resume() {
        player?.play()
        isPlaying = true
    }

    /// Function to load audio in the media player
    func loadAudio(for episode: Episode) async throws {
        // Episode url not available
        guard let audioURLString = episode.url else {
            throw PodcastAppError.invalidURL
        }
        // Episode url is invalid
        guard let url = URL(string: audioURLString) else {
            throw PodcastAppError.invalidURL
        }
        
        removeTimeObserver()
        
        let player = AVPlayer(url: url)
        self.player = player
        
        let asset = AVURLAsset(url: url)
        do {
            let loadedDuration = try await asset.load(.duration)
            await MainActor.run {
                self.duration = CMTimeGetSeconds(loadedDuration)
            }
        } catch {
            throw PodcastAppError.unknown(error)
        }
        
        addTimeObserver(to: player)
    }

    /// Switches play and pause toggle
    func togglePlayPause() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }

        isPlaying.toggle()
    }
    
    /// Switches play and pause toggle for episode
    func togglePlayback(for episode: Episode, podcast: Podcast) {
        Task {
            do {
                if isCurrentEpisode(episode) {
                    if isPlaying {
                        pause()
                    } else {
                        resume()
                    }
                } else {
                    try await play(episode: episode, podcast: podcast)
                }
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }

    /// Moves forward or backward with min 0 and max duration +/- 10 seconds
    func skip(seconds: Double) {
        guard let player = player else { return }

        let current = CMTimeGetSeconds(player.currentTime())
        let newTime = max(0, min(current + seconds, duration))
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
    }

    /// Moves playback to the given time
    func seek(to time: Double) {
        guard let player = player else { return }
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime)
        currentTime = time
    }

    /// Converts seconds to mm:ss
    func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    /// Runs progress bar real time
    private func addTimeObserver(to player: AVPlayer) {
        let interval = CMTime(seconds: 1, preferredTimescale: 600)

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
        }
    }
    
    /// Cleans up timeobserver
    private func removeTimeObserver() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}
