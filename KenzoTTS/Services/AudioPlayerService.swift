//
//  AudioPlayerService.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import Foundation
import AVFoundation
import Combine

class AudioPlayerService: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var audioData: Data?
    @Published var generatedText: String = ""
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func loadAudio(data: Data, text: String) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            audioData = data
            generatedText = text
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
        } catch {
            print("Failed to load audio: \(error)")
        }
    }
    
    func play() {
        guard let player = audioPlayer else { return }
        
        if player.play() {
            isPlaying = true
            startTimer()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func clearAudio() {
        stop()
        audioPlayer = nil
        audioData = nil
        generatedText = ""
        duration = 0
        currentTime = 0
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
}
