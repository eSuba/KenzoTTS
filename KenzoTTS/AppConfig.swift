//
//  AppConfig.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import Foundation

// A curated voice descriptor used for selection UI.
// This wraps an ElevenLabs voice id and some display metadata.
struct VoiceStyle: Identifiable, Equatable, Hashable {
    let id: String              // Stable identifier for the style (usually the voice id)
    let displayName: String
    let elevenLabsVoiceId: String
    let language: String        // e.g. "English", "French", ...
    let accent: String?         // e.g. "American", "British"
}

enum AppConfig {
    // Language filters displayed at the top of selection sheet
    static let languages: [String] = [
        "Default",
        "English",
        "German",
        "Portuguese",
        "Italian",
        "French",
        "Indian",
        "Vietnamese",
        "Arabic",
        "Spanish",
        "Chinese",
        "Japanese",
        "Korean"
    ]
    
    static let englishAccents: [String] = ["American", "British"]
    
    // Curated non-celebrity ElevenLabs voices
    // Source: ElevenLabs premade voices catalogue
    static let allVoices: [VoiceStyle] = [
        // American English
        VoiceStyle(id: "adam",    displayName: "Adam",    elevenLabsVoiceId: "pNInz6obpgDQGcFmaJgB", language: "English", accent: "American"),
        VoiceStyle(id: "aria",    displayName: "Aria",    elevenLabsVoiceId: "9BWtsMINqrJLrRacOk9x", language: "English", accent: "American"),
        VoiceStyle(id: "brian",   displayName: "Brian",   elevenLabsVoiceId: "nPczCjzI2devNBz1zQrb", language: "English", accent: "American"),
        VoiceStyle(id: "daniel",  displayName: "Daniel",  elevenLabsVoiceId: "onwK4e9ZLuTAKqWW03F9", language: "English", accent: "American"),
        VoiceStyle(id: "eric",    displayName: "Eric",    elevenLabsVoiceId: "cjVigY5qzO86Huf0OWal", language: "English", accent: "American"),
        VoiceStyle(id: "chris",   displayName: "Chris",   elevenLabsVoiceId: "iP95p4xoKVk53GoZ742B", language: "English", accent: "American"),
        VoiceStyle(id: "jessica", displayName: "Jessica", elevenLabsVoiceId: "cgSgspJ2msm6clMCkdW9", language: "English", accent: "American"),
        VoiceStyle(id: "laura",   displayName: "Laura",   elevenLabsVoiceId: "FGY2WhTYpPnrIDTdsKH5", language: "English", accent: "American"),
        VoiceStyle(id: "roger",   displayName: "Roger",   elevenLabsVoiceId: "CwhRBWXzGAHq8TQ4Fs17", language: "English", accent: "American"),
        VoiceStyle(id: "sarah",   displayName: "Sarah",   elevenLabsVoiceId: "EXAVITQu4vr4xnSDxMaL", language: "English", accent: "American"),
        VoiceStyle(id: "will",    displayName: "Will",    elevenLabsVoiceId: "bIHbv24MWmeRgasZH58o", language: "English", accent: "American"),
        VoiceStyle(id: "lily",    displayName: "Lily",    elevenLabsVoiceId: "pFZP5JQG7iQjIQuC4Bku", language: "English", accent: "American"),
        VoiceStyle(id: "bill",    displayName: "Bill",    elevenLabsVoiceId: "pqHfZKP75CvOlQylNhV4", language: "English", accent: "American"),
        VoiceStyle(id: "river",   displayName: "River",   elevenLabsVoiceId: "SAz9YHcvj6GT2YYXdXww", language: "English", accent: "American"),
        VoiceStyle(id: "josh",    displayName: "Josh",    elevenLabsVoiceId: "TxGEqnHWrfWFTfGW9XjX", language: "English", accent: "American"),
        
        // British English
        VoiceStyle(id: "callum",  displayName: "Callum",  elevenLabsVoiceId: "N2lVS1w4EtoT3dr4eOWO", language: "English", accent: "British"),
        VoiceStyle(id: "charlie", displayName: "Charlie", elevenLabsVoiceId: "IKne3meq5aSn9XLyUdCD", language: "English", accent: "British"),
        VoiceStyle(id: "george",  displayName: "George",  elevenLabsVoiceId: "JBFqnCBsd6RMkjVDRZzb", language: "English", accent: "British"),
        
        // Other languages (small curated set)
        VoiceStyle(id: "alice",   displayName: "Alice",   elevenLabsVoiceId: "Xb7hH8MSUJpSbSDYk0k2", language: "French", accent: nil),
        VoiceStyle(id: "liam",    displayName: "Liam",    elevenLabsVoiceId: "TX3LPaxmHKxFdv7VOQHJ", language: "German", accent: nil),
        VoiceStyle(id: "matilda", displayName: "Matilda", elevenLabsVoiceId: "XrExE9yKIg1WjnnlVkGX", language: "Italian", accent: nil)
    ]
    
    // Default list shown when no filter is applied
    static var defaultAIVoices: [VoiceStyle] {
        return [
            voice(named: "Brian"), voice(named: "Adam"), voice(named: "Aria"),
            voice(named: "Callum"), voice(named: "Charlie"), voice(named: "George"),
            voice(named: "Jessica"), voice(named: "Eric"), voice(named: "Chris")
        ].compactMap { $0 }
    }
    
    static func voices(forLanguage language: String, accent: String? = nil) -> [VoiceStyle] {
        if language == "English" {
            if let accent = accent { return allVoices.filter { $0.language == language && $0.accent == accent } }
            return allVoices.filter { $0.language == language }
        }
        return allVoices.filter { $0.language == language }
    }
    
    private static func voice(named name: String) -> VoiceStyle? {
        return allVoices.first { $0.displayName.caseInsensitiveCompare(name) == .orderedSame }
    }
}


