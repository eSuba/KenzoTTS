//
//  AudioPlayerView.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayerService
    let selectedVoice: Voice
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar (smoothed but stable at end)
            let p = audioPlayer.duration > 0 ? min(max(audioPlayer.currentTime / audioPlayer.duration, 0), 1) : 0
            ProgressView(value: p)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .scaleEffect(y: 2)
                // Keep progress smooth, but avoid fade/twitch at completion
                .animation(p > 0 && p < 1 ? .linear(duration: 0.05) : .none, value: p)
                .padding()
            
            HStack {
                // Time labels
                Text(formatTime(audioPlayer.currentTime))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(formatTime(audioPlayer.duration))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Generated text display
            Text(audioPlayer.generatedText)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Voice and controls
            HStack {
                // Voice info
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text(selectedVoice.name)
                        .font(.body)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            audioPlayer.play()
                        }
                    }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        // Share functionality
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        audioPlayer.clearAudio()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
