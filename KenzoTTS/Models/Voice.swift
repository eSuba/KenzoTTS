//
//  Voice.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import Foundation

struct Voice: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let description: String?
    let previewUrl: String?
    let availableForTiers: [String]
    let settings: VoiceSettings?
    
    enum CodingKeys: String, CodingKey {
        case id = "voice_id"
        case name
        case category
        case description
        case previewUrl = "preview_url"
        case availableForTiers = "available_for_tiers"
        case settings
    }
    
    // Default Brian voice for the app
    static let brian = Voice(
        id: "nPczCjzI2devNBz1zQrb",
        name: "Brian",
        category: "premade",
        description: "A reliable and pleasant American male voice",
        previewUrl: nil,
        availableForTiers: ["free"],
        settings: VoiceSettings(stability: 0.5, similarityBoost: 0.5, style: 0.0, useSpeakerBoost: true)
    )
}

struct VoiceSettings: Codable {
    let stability: Double
    let similarityBoost: Double
    let style: Double
    let useSpeakerBoost: Bool
    
    enum CodingKeys: String, CodingKey {
        case stability
        case similarityBoost = "similarity_boost"
        case style
        case useSpeakerBoost = "use_speaker_boost"
    }
}

struct VoicesResponse: Codable {
    let voices: [Voice]
}

// MARK: - V2 Voices (Public Library)

struct VoiceV2: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    let previewUrl: String?
    let labels: VoiceV2Labels?
    
    enum CodingKeys: String, CodingKey {
        case id = "voice_id"
        case name
        case description
        case previewUrl = "preview_url"
        case labels
    }
}

struct VoiceV2Labels: Codable, Hashable {
    let language: String?
    let descriptive: String?
    let age: String?
    let gender: String?
    let useCase: String?
    
    enum CodingKeys: String, CodingKey {
        case language
        case descriptive
        case age
        case gender
        case useCase = "use_case"
    }
}

struct VoicesV2Response: Codable {
    let voices: [VoiceV2]
    let hasMore: Bool?
    let totalCount: Int?
    let nextPageToken: String?
    
    enum CodingKeys: String, CodingKey {
        case voices
        case hasMore = "has_more"
        case totalCount = "total_count"
        case nextPageToken = "next_page_token"
    }
}
