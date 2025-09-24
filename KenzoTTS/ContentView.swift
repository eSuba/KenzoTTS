//
//  ContentView.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var elevenLabsService: ElevenLabsService
    @StateObject private var audioPlayer = AudioPlayerService()
    
    @State private var inputText = ""
    @State private var selectedVoice = AppConfig.defaultAIVoices.first ?? VoiceStyle(id: "brian", displayName: "Brian", elevenLabsVoiceId: "nPczCjzI2devNBz1zQrb", language: "English", accent: "American")
    @State private var showingVoiceSelection = false
    @State private var availableVoices: [VoiceStyle] = AppConfig.defaultAIVoices
    @FocusState private var isInputFocused: Bool
    
    private let placeholder = "Start typing here..."
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("IIElevenLabs")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "person.crop.circle")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                Spacer(minLength: 24)
                
                // Large typing area with big placeholder
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $inputText)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($isInputFocused)
                        .onAppear { isInputFocused = true }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    if inputText.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(.white.opacity(0.25))
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Audio player (only when generated)
                if audioPlayer.audioData != nil {
                    // Map for display only; player UI just shows the name
                    AudioPlayerView(audioPlayer: audioPlayer, selectedVoice: Voice(id: selectedVoice.elevenLabsVoiceId, name: selectedVoice.displayName, category: "premade", description: nil, previewUrl: nil, availableForTiers: [], settings: nil))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        // Floating controls above keyboard (outside toolbar)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 14) {
                Button { showingVoiceSelection = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill").foregroundColor(.blue)
                        Text(selectedVoice.displayName)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(18)
                }
                Spacer(minLength: 10)
                Button(action: generateSpeech) {
                    if elevenLabsService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(0.8)
                            .frame(minWidth: 110)
                    } else {
                        Text(audioPlayer.audioData != nil ? "Regenerate" : "Generate")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(minWidth: 110)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Color.white.opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.2 : 1.0)
                )
                .foregroundColor(
                    inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.7) : .black
                )
                .cornerRadius(22)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || elevenLabsService.isLoading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                TopRoundedRectangle(radius: 22)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        TopRoundedRectangle(radius: 22)
                            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                    .ignoresSafeArea(edges: .bottom)
            )

        }
        .sheet(isPresented: $showingVoiceSelection) {
            VoiceSelectionViewV2(
                selectedVoice: $selectedVoice,
                isPresented: $showingVoiceSelection
            )
            .environmentObject(elevenLabsService)
        }
        .onAppear { loadVoices() }
        .alert("Error", isPresented: .constant(elevenLabsService.errorMessage != nil)) {
            Button("OK") { elevenLabsService.errorMessage = nil }
        } message: {
            Text(elevenLabsService.errorMessage ?? "")
        }
    }
        
    private func generateSpeech() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        elevenLabsService.generateSpeech(text: text, voiceId: selectedVoice.elevenLabsVoiceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioData):
                    audioPlayer.loadAudio(data: audioData, text: text)
                case .failure(let error):
                    print("Failed to generate speech: \(error)")
                }
            }
        }
    }
    
    private func loadVoices() {
        // Use curated non-celebrity voices from AppConfig
        availableVoices = AppConfig.defaultAIVoices
    }
}

private struct TopRoundedRectangle: Shape {
    var radius: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        let corners: UIRectCorner = [.topLeft, .topRight]
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ContentView()
}
