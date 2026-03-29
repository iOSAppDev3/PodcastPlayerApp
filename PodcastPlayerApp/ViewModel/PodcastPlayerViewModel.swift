//
//  PodcastPlayerViewModel.swift
//  PodcastPlayerApp
//
//  Created by Bakkiya Murugan on 28/03/2026.
//

import AVFoundation

enum PlayerState: Equatable {
    case idle
    case loading(episodeID: Int)
    case playing(episodeID: Int)
    case paused(episodeID: Int)
    case failed(message: String)
}

@MainActor
final class PodcastPlayerViewModel: ObservableObject {
    @Published var currentEpisode: Episode?
    @Published var currentPodcast: Podcast?
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var playerState: PlayerState = .idle
   
    var isPlaying: Bool {
        if case .playing = playerState {
            return true
        }
        return false
    }

    var isLoading: Bool {
        if case .loading = playerState {
            return true
        }
        return false
    }
    
    private let audioPlayer: PodcastAudioPlayerServiceProtocol
    
    init(audioPlayer: PodcastAudioPlayerServiceProtocol = PodcastAudioPlayerService()) {
        self.audioPlayer = audioPlayer
    }

    deinit {
        audioPlayer.removeTimeObserver()
    }

    func isCurrentEpisode(_ episode: Episode) -> Bool {
        currentEpisode?.id == episode.id
    }

    @MainActor
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

    func pause() {
        audioPlayer.pause()
        if let id = currentEpisode?.id {
            playerState = .paused(episodeID: id)
        }
    }

    func resume() {
        audioPlayer.play()
        if let id = currentEpisode?.id {
            playerState = .playing(episodeID: id)
        }
    }
    
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
    
    func togglePlayback(for episode: Episode, podcast: Podcast) async {
        switch playerState {
        case .loading(let id) where id == episode.id:
            return // ignore taps while loading

        case .playing(let id) where id == episode.id:
            pause()

        case .paused(let id) where id == episode.id:
            resume()

        default:
            await play(episode: episode, podcast: podcast)
        }
    }

    func skip(seconds: Double) {
        audioPlayer.skip(seconds: seconds)
    }

    func seek(to time: Double) {
        audioPlayer.seek(to: time)
        currentTime = time
    }

    func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
