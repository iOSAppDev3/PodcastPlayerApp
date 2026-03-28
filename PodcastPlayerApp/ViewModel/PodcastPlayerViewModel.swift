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
    /// Play/pause button state
    @Published var isPlaying = false
    /// Progress bar position
    @Published var currentTime: Double = 0
    /// Total length of the audio
    @Published var duration: Double = 0
    /// Audio player
    private var player: AVPlayer?
    /// Listener that tracks playback progress
    private var timeObserver: Any?
    
    /// Function to play an epsiode
    func play(episode: Episode) {
        currentEpisode = episode
        loadAudio(for: episode)
        isPlaying = true
    }

    /// Function to load audio in the media player
    func loadAudio(for episode: Episode) {
        guard let url = URL(string:"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!
        player = AVPlayer(url: url)

        if let player = player {
            let asset =  AVURLAsset(url: url)
            Task {
                do {
                    let duration = try await asset.load(.duration)
                    await MainActor.run {
                        ///  Converts CMTime to seconds (double)
                        self.duration = CMTimeGetSeconds(duration)
                    }
                } catch {
                    print("Failed to load duration: \(error)")
                }
            }

            addTimeObserver(to: player)
        }
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
    deinit {
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
        }
    }
}
