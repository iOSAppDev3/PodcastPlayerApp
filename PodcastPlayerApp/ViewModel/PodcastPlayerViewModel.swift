//
//  PodcastPlayerViewModel.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import AVFoundation

/// Enum represents the current state of the podcast player.
enum PlayerState: Equatable {
    
    /// No episode is currently selected or playing.
    case idle
    
    /// An episode is currently being loaded.
    case loading(episodeID: Int)
    
    /// An episode is actively playing.
    case playing(episodeID: Int)
    
    /// Playback is paused for the current episode.
    case paused(episodeID: Int)
    
    /// Playback failed with an error message.
    case failed(message: String)
}

/// View model responsible for managing podcast audio playback state.
///
/// This class coordinates audio playback, exposes player state to the UI,
/// and handles playback actions such as play, pause, resume, seek, and skip.
@MainActor
final class PodcastPlayerViewModel: ObservableObject {
    
    /// The currently selected episode.
    @Published var currentEpisode: Episode?
    
    /// The podcast associated with the current episode.
    @Published var currentPodcast: Podcast?
    
    /// The current playback time in seconds.
    @Published var currentTime: Double = 0
    
    /// The total duration of the loaded episode in seconds.
    @Published var duration: Double = 0
    
    /// Error message to display when playback fails.
    @Published var errorMessage: String?
    
    /// Controls whether an error alert should be shown.
    @Published var showErrorAlert = false
    
    /// The current playback state.
    @Published var playerState: PlayerState = .idle
   
    /// Indicates whether audio is currently playing.
    var isPlaying: Bool {
        if case .playing = playerState {
            return true
        }
        return false
    }

    /// Indicates whether an episode is currently loading.
    var isLoading: Bool {
        if case .loading = playerState {
            return true
        }
        return false
    }
    
    /// Service used to handle audio playback.
    private let audioPlayer: PodcastAudioPlayerServiceProtocol
    
    /// Creates a new player view model.
    ///
    /// - Parameter audioPlayer: The audio player service used for playback
    init(audioPlayer: PodcastAudioPlayerServiceProtocol = PodcastAudioPlayerService()) {
        self.audioPlayer = audioPlayer
    }

    deinit {
        audioPlayer.removeTimeObserver()
    }

    /// Returns whether the given episode is the currently selected episode.
    ///
    /// - Parameter episode: The episode to compare.
    /// - Returns: `true` if the episode is currently selected, otherwise `false`.
    func isCurrentEpisode(_ episode: Episode) -> Bool {
        currentEpisode?.id == episode.id
    }

    /// Loads and starts playback for the given episode.
    ///
    /// This method validates the episode URL, loads the audio, updates playback
    /// metadata, starts observing time changes, and begins playback.
    ///
    /// - Parameters:
    ///   - episode: The episode to play.
    ///   - podcast: The podcast of the episode
    func play(episode: Episode, podcast: Podcast) async {
        playerState = .loading(episodeID: episode.id)

        do {
            guard let audioURLString = episode.url,
                  let url = URL(string: audioURLString) else {
                throw PodcastAppError.invalidURL
            }
            currentPodcast = podcast
            currentEpisode = episode

            try await audioPlayer.loadAudio(from: url)

            duration = audioPlayer.duration

            audioPlayer.addTimeObserver { [weak self] time in
                self?.currentTime = time
            }

            audioPlayer.play()
            errorMessage = nil
            showErrorAlert = false
            playerState = .playing(episodeID: episode.id)

        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            playerState = .failed(message: error.localizedDescription)
        }
    }

    /// Pauses playback of the current episode.
    func pause() {
        audioPlayer.pause()
        if let id = currentEpisode?.id {
            playerState = .paused(episodeID: id)
        }
    }

    /// Resumes playback of the current episode.
    func resume() {
        audioPlayer.play()
        if let id = currentEpisode?.id {
            playerState = .playing(episodeID: id)
        }
    }
    
    /// Toggles playback between play and pause for the current episode.
    func togglePlayPause() {
        switch playerState {
        case .playing:
            pause()
        case .paused:
            resume()
        default:
            break
        }
    }

    /// Skips playback forward or backward by the given number of seconds.
    ///
    /// - Parameter seconds: Positive to skip forward, negative to skip backward
    func skip(seconds: Double) {
        audioPlayer.skip(seconds: seconds)
    }

    /// Seeks playback to a specific time.
    ///
    /// - Parameter time: The target playback time in seconds.
    func seek(to time: Double) {
        audioPlayer.seek(to: time)
        currentTime = time
    }

    /// Formats a time interval in seconds as a `mm:ss` string.
    ///
    /// - Parameter seconds: The time interval in seconds.
    /// - Returns: A formatted time string.
    func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
