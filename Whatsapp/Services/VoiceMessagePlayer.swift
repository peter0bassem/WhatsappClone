//
//  VoiceMessagePlayer.swift
//  Whatsapp
//
//  Created by iCommunity app on 04/09/2024.
//

import Foundation
import AVFoundation

final class VoiceMessagePlayer: ObservableObject {
    private var player: AVPlayer?
    private(set) var currentURL: URL?
    private var playerItem: AVPlayerItem?
    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var currentAudioTime = CMTime.zero
    private var currentTimeObserver: Any?
    
    deinit {
        tearDown()
    }
    
    func playAudio(from url: URL) {
        if currentURL != nil, currentURL == url {
            resumePlayingAudio()
        } else {
            stopAudio()
            currentURL = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            self.player = .init(playerItem: playerItem)
            self.player?.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayback()
        }
    }
    
    func pauseAudio() {
        player?.pause()
        playbackState = .paused
    }
    
    func seek(to timeInterval: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    private func resumePlayingAudio() {
        if playbackState == .paused || playbackState == .stopped {
            player?.play()
            playbackState = .playing
        }
    }
    
    private func observeCurrentPlayerTime() {
        currentTimeObserver = player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.currentAudioTime = time
        }
    }
    
    private func observeEndOfPlayback() {
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.stopAudio()
        }
    }
    
    private func stopAudio() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentAudioTime = .zero
    }
    
    private func removeObservers() {
        guard let currentTimeObserver = currentTimeObserver else { return }
        player?.removeTimeObserver(currentTimeObserver)
        self.currentTimeObserver = nil
    }
    
    private func tearDown() {
        removeObservers()
        player = nil
        playerItem = nil
        currentURL = nil
    }
}

extension VoiceMessagePlayer {
    enum PlaybackState {
        case stopped
        case playing
        case paused
        
        var icon: String {
            return self == .playing ? "pause.fill" : "play.fill"
        }
    }
}
