//
//  ElevenLabsService.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import Foundation
import AVFoundation

class ElevenLabsService: ObservableObject {
    private let baseURL = "https://api.elevenlabs.io/v1"
    private let baseURLV2 = "https://api.elevenlabs.io/v2"
    private let apiKey = "sk_31db27550394e903d91a6b95c3f58bf8891f0bd8ef6e7192"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var libraryVoices: [VoiceV2] = []
    @Published var isFetchingLibrary: Bool = false
    
    // Pagination state for v2 library
    private var nextPageToken: String? = nil
    private let defaultPageSize: Int = 10
    
    // Simple persistence for My Voices
    @Published var myVoiceIds: Set<String> = [] {
        didSet { saveMyVoices() }
    }
    private let myVoicesKey = "KenzoTTS.myVoiceIds"
    
    init() {
        loadMyVoices()
    }
    
    func generateSpeech(text: String, voiceId: String, completion: @escaping (Result<Data, Error>) -> Void) {

        
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.5,
                "style": 0.0,
                "use_speaker_boost": true
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to create request"
            }
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(TTSError.invalidResponse))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMsg = "HTTP Error: \(httpResponse.statusCode)"
                DispatchQueue.main.async {
                    self?.errorMessage = errorMsg
                }
                completion(.failure(TTSError.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(TTSError.noData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    func fetchVoices(completion: @escaping (Result<[Voice], Error>) -> Void) {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(TTSError.invalidAPIKey))
            return
        }
        
        let url = URL(string: "\(baseURL)/voices")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(TTSError.noData))
                return
            }
            
            do {
                let voicesResponse = try JSONDecoder().decode(VoicesResponse.self, from: data)
                completion(.success(voicesResponse.voices))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Public Library Voices (V2) with pagination
    func fetchPublicLibraryVoices(pageSize: Int = 100) async {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            await MainActor.run { self.errorMessage = TTSError.invalidAPIKey.localizedDescription }
            return
        }
        var aggregated: [VoiceV2] = []
        var nextToken: String? = nil
        do {
            repeat {
                var components = URLComponents(string: "\(baseURLV2)/voices")!
                var items: [URLQueryItem] = [URLQueryItem(name: "page_size", value: String(pageSize))]
                if let token = nextToken, !token.isEmpty {
                    items.append(URLQueryItem(name: "next_page_token", value: token))
                }
                components.queryItems = items
                var request = URLRequest(url: components.url!)
                request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")

                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    throw TTSError.invalidResponse
                }
                let decoded = try JSONDecoder().decode(VoicesV2Response.self, from: data)
                aggregated.append(contentsOf: decoded.voices)
                nextToken = decoded.nextPageToken
            } while (nextToken != nil && !(nextToken ?? "").isEmpty)
            await MainActor.run { self.libraryVoices = aggregated }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }

    // Fetch first page or next page (10 at a time by default)
    @MainActor
    func resetLibraryPagination() {
        libraryVoices = []
        nextPageToken = nil
    }
    
    func fetchNextLibraryPage(pageSize: Int? = nil) async {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else { return }
        let alreadyFetching = await MainActor.run { self.isFetchingLibrary }
        if alreadyFetching { return }
        let tokenSnapshot = await MainActor.run { self.nextPageToken }
        if let token = tokenSnapshot, token.isEmpty { return }
        await MainActor.run { self.isFetchingLibrary = true }
        do {
            var components = URLComponents(string: "\(baseURLV2)/voices")!
            var items: [URLQueryItem] = [URLQueryItem(name: "page_size", value: String(pageSize ?? defaultPageSize))]
            if let token = tokenSnapshot, !token.isEmpty {
                items.append(URLQueryItem(name: "next_page_token", value: token))
            }
            components.queryItems = items
            var request = URLRequest(url: components.url!)
            request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { throw TTSError.invalidResponse }
            let decoded = try JSONDecoder().decode(VoicesV2Response.self, from: data)
            // Debug prints for decoding purpose
            let pageVoices = decoded.voices
            print("Fetched voices page: count=\(pageVoices.count), next_token=\(decoded.nextPageToken ?? "<nil>")")
            for v in pageVoices {
                let lang = v.labels?.language ?? ""
                let desc = v.labels?.descriptive ?? ""
                let use = v.labels?.useCase ?? ""
                print("- Voice id=\(v.id) name=\(v.name) lang=\(lang) use=\(use) desc=\(desc) preview=\(v.previewUrl ?? "")")
            }
            await MainActor.run {
                // Defensive: avoid duplicates if API sometimes repeats entries
                let existingIds = Set(self.libraryVoices.map { $0.id })
                let newOnes = decoded.voices.filter { !existingIds.contains($0.id) }
                self.libraryVoices.append(contentsOf: newOnes)
                self.nextPageToken = decoded.nextPageToken
                self.isFetchingLibrary = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isFetchingLibrary = false
            }
        }
    }
    
    var hasMoreLibraryPages: Bool { (nextPageToken ?? "").isEmpty == false }
    
    // MARK: - My Voices management
    @MainActor func isMyVoice(id: String) -> Bool { myVoiceIds.contains(id) }
    @MainActor func addToMyVoices(id: String) { myVoiceIds.insert(id) }
    @MainActor func removeFromMyVoices(id: String) { myVoiceIds.remove(id) }
    
    private func loadMyVoices() {
        if let stored = UserDefaults.standard.array(forKey: myVoicesKey) as? [String] {
            myVoiceIds = Set(stored)
        } else {
            myVoiceIds = []
        }
    }
    private func saveMyVoices() {
        UserDefaults.standard.set(Array(myVoiceIds), forKey: myVoicesKey)
    }
}

enum TTSError: LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case noData
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Please set your ElevenLabs API key"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        }
    }
}
