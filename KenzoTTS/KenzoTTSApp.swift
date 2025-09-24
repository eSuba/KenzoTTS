//
//  KenzoTTSApp.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import SwiftUI

@main
struct KenzoTTSApp: App {
    @StateObject private var eleven = ElevenLabsService()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eleven)
                .task {
                    // Start fresh and fetch only the first 10 voices
                    await MainActor.run { eleven.resetLibraryPagination() }
                    await eleven.fetchNextLibraryPage(pageSize: 10)
                }
        }
    }
}
