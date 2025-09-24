//
//  VoiceSelectionView.swift
//  KenzoTTS
//
//  Created by Mohamed on 14/08/2025.
//

import SwiftUI
import AVKit

// New V2 voice selection using public library voices
struct VoiceSelectionViewV2: View {
    @Binding var selectedVoice: VoiceStyle
    @Binding var isPresented: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var eleven: ElevenLabsService
    
    @State private var activeTab: Int = 1 // default to Explore
    @State private var showFilters: Bool = false
    @State private var showFiltersSheet: Bool = false
    @State private var searchText: String = ""
    @State private var selectedLanguage: String? = nil
    @State private var selectedUseCase: String? = nil
    @State private var selectedAge: String? = nil
    @State private var selectedGender: String? = nil
    
    // Selection and preview state
    @State private var pendingSelectedId: String? = nil
    @State private var playingId: String? = nil
    @State private var player: AVPlayer? = nil
    
    // Preserve load order; just filter. Newly fetched items appear at the bottom.
    private var sortedFiltered: [VoiceV2] {
        let filtered = eleven.libraryVoices.filter { v in
            let lbl = v.labels
            let matchesLang = selectedLanguage == nil || lbl?.language?.lowercased() == selectedLanguage?.lowercased()
            let matchesUse = selectedUseCase == nil || lbl?.useCase?.lowercased() == selectedUseCase?.lowercased()
            let matchesAge = selectedAge == nil || lbl?.age?.lowercased() == selectedAge?.lowercased()
            let matchesGender = selectedGender == nil || lbl?.gender?.lowercased() == selectedGender?.lowercased()
            return matchesLang && matchesUse && matchesAge && matchesGender
        }
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                tabBar
                if showFilters { filterBar }
                content
            }
            .navigationBarHidden(true)
            .task {
                if eleven.libraryVoices.isEmpty {
                    await eleven.fetchNextLibraryPage()
                }
            }
            .onDisappear { stopPreview() }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button(action: applySelection) {
                    Text("Select voice")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .disabled(pendingSelectedId == nil)
                .opacity(pendingSelectedId == nil ? 0.6 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear)
        }
        .sheet(isPresented: $showFiltersSheet) {
            FilterSheet(
                selectedLanguage: $selectedLanguage,
                selectedUseCase: $selectedUseCase,
                selectedAge: $selectedAge,
                selectedGender: $selectedGender,
                languages: languageOptions(),
                useCases: useCaseOptions()
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterMenu(title: "Lang", selection: $selectedLanguage, options: languageOptions())
                FilterMenu(title: "Use", selection: $selectedUseCase, options: useCaseOptions())
                FilterMenu(title: "Age", selection: $selectedAge, options: ["young","middle_aged","old"]) 
                FilterMenu(title: "Gender", selection: $selectedGender, options: ["female","male","neutral"]) 
                if selectedLanguage != nil || selectedUseCase != nil || selectedAge != nil || selectedGender != nil {
                    Button("Reset") {
                        selectedLanguage = nil
                        selectedUseCase = nil
                        selectedAge = nil
                        selectedGender = nil
                    }
                    .font(.callout)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.secondary.opacity(0.15)))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.secondarySystemBackground))
    }
    
    private func languageOptions() -> [String] {
        Array(Set(eleven.libraryVoices.compactMap { $0.labels?.language?.lowercased() })).sorted()
    }
    private func useCaseOptions() -> [String] {
        Array(Set(eleven.libraryVoices.compactMap { $0.labels?.useCase?.lowercased() })).sorted()
    }
}

private extension VoiceSelectionViewV2 {
    func handleRowTap(_ v: VoiceV2) {
        pendingSelectedId = v.id
        if playingId == v.id {
            stopPreview()
            return
        }
        startPreview(for: v)
    }
    
    func startPreview(for v: VoiceV2) {
        stopPreview()
        guard let urlStr = v.previewUrl, let url = URL(string: urlStr) else { return }
        playingId = v.id
        player = AVPlayer(url: url)
        player?.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
            playingId = nil
        }
    }
    
    func stopPreview() {
        player?.pause()
        player = nil
        playingId = nil
    }
    
    
    func applySelection() {
        guard let id = pendingSelectedId else { return }
        stopPreview()
        if id == "brian" {
            selectedVoice = VoiceStyle(id: "brian", displayName: "Brian", elevenLabsVoiceId: "nPczCjzI2devNBz1zQrb", language: "EN", accent: "American")
        } else if let v = eleven.libraryVoices.first(where: { $0.id == id }) {
            selectedVoice = VoiceStyle(id: v.id, displayName: v.name, elevenLabsVoiceId: v.id, language: v.labels?.language?.uppercased() ?? "", accent: nil)
        }
        isPresented = false
    }
    var header: some View {
        HStack(alignment: .center) {
            Text("Voices")
                .font(.system(size: 40, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                Button { showFiltersSheet = true } label: {
                    Image(systemName: "slider.horizontal.3")
                        .padding(10)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Circle())
                }
                Button { /* search trigger, search bar below */ } label: {
                    Image(systemName: "magnifyingglass")
                        .padding(10)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Circle())
                }
            }
                }
                .padding(.horizontal)
                .padding(.top, 8)
        .padding(.bottom, 8)
    }
    var tabBar: some View {
        HStack(spacing: 12) {
            SegmentedTab(title: "My voices", isActive: activeTab == 0) { activeTab = 0 }
            SegmentedTab(title: "Explore", isActive: activeTab == 1) { activeTab = 1 }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    var content: some View {
        Group { activeTab == 0 ? AnyView(myVoicesList) : AnyView(exploreList) }
    }
    
    var myVoicesList: some View {
        List {
            Section(header: Text("Default voices")) {
                MyVoiceRow(title: "Brian", subtitle: "Casual · Conversational", isSelected: pendingSelectedId == "brian", onRemove: nil) {
                    pendingSelectedId = "brian"
                    stopPreview()
                }
            }
            if !eleven.myVoiceIds.isEmpty {
                Section(header: Text("Voices you added")) {
                    ForEach(eleven.libraryVoices.filter { eleven.myVoiceIds.contains($0.id) }) { v in
                        MyVoiceRow(title: v.name, subtitle: mySubtitle(for: v), isSelected: pendingSelectedId == v.id, onRemove: {
                            Task { await eleven.removeFromMyVoices(id: v.id) }
                        }) {
                            handleRowTap(v)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listRowSeparator(.hidden)
    }
    
    func mySubtitle(for v: VoiceV2) -> String {
        let a = (v.labels?.descriptive?.capitalized ?? "").trimmingCharacters(in: .whitespaces)
        let b = (v.labels?.useCase?.replacingOccurrences(of: "_", with: " ").capitalized ?? "")
        if a.isEmpty { return b }
        if b.isEmpty { return a }
        return "\(a) · \(b)"
    }
    
    var exploreList: some View {
        Group {
            if eleven.isFetchingLibrary && eleven.libraryVoices.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading voices...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedFiltered.filter { searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText) }) { v in
                        VoiceExploreRow(
                            voice: v,
                            isSelected: pendingSelectedId == v.id,
                            isPlaying: playingId == v.id,
                            isAdded: eleven.isMyVoice(id: v.id),
                            onAdd: { eleven.addToMyVoices(id: v.id) },
                            onRemove: { eleven.removeFromMyVoices(id: v.id) },
                            onTap: { handleRowTap(v) }
                        )
                    }
                    if eleven.hasMoreLibraryPages || eleven.isFetchingLibrary {
                        HStack {
                            Spacer()
                            ProgressView("Loading more...")
                            Spacer()
                        }
                        .onAppear {
                            if eleven.hasMoreLibraryPages && !eleven.isFetchingLibrary {
                                Task { await eleven.fetchNextLibraryPage() }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search voices"))
            }
        }
    }
}

private struct SegmentedTab: View {
    let title: String
    let isActive: Bool
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .fontWeight(.semibold)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isActive ? Color.white : Color.clear)
                .foregroundColor(isActive ? .black : .white)
                .overlay(Capsule().stroke(isActive ? Color.clear : Color.white.opacity(0.3), lineWidth: 1))
                .clipShape(Capsule())
        }
    }
}

private struct MyVoiceRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onRemove: (() -> Void)?
    let onSelect: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(LinearGradient(colors: [Color.purple.opacity(0.7), Color.pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            if isSelected { Image(systemName: "checkmark.circle.fill").foregroundColor(.white).padding(8).background(Color.gray.opacity(0.35)).clipShape(Circle()) }
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
    }
}

private struct VoiceExploreRow: View {
    let voice: VoiceV2
    let isSelected: Bool
    let isPlaying: Bool
    let isAdded: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient(colors: [Color.green.opacity(0.7), Color.blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                if isPlaying {
                    Image(systemName: "pause.fill")
                        .foregroundColor(.white)
                        .padding(10)
                }
            }
            .onTapGesture { onTap() }
            VStack(alignment: .leading, spacing: 4) {
                Text(voice.name).font(.headline)
                Text(subtitle).font(.caption).bold().foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .padding(.trailing, 6)
            }
            Button(action: { isAdded ? onRemove() : onAdd() }) {
                Image(systemName: isAdded ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundColor(Color.white.opacity(isAdded ? 0.4 : 1))
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
    
    private var subtitle: String {
        let a = (voice.labels?.descriptive?.capitalized ?? "").trimmingCharacters(in: .whitespaces)
        let b = (voice.labels?.useCase?.replacingOccurrences(of: "_", with: " ").capitalized ?? "")
        if a.isEmpty { return b }
        if b.isEmpty { return a }
        return "\(a) · \(b)"
    }
}
private struct FilterMenu: View {
    let title: String
    @Binding var selection: String?
    let options: [String]
    
    var body: some View {
        Menu {
            Button("Any") { selection = nil }
            ForEach(options, id: \.self) { opt in
                Button(opt) { selection = opt }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection ?? title)
                    .font(.callout).fontWeight(.semibold)
                Image(systemName: "chevron.down").font(.system(size: 14))
                    }
                    .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.secondary.opacity(0.15)))
        }
    }
}

// Deprecated old row type retained for reference; new rows use VoiceExploreRow

private struct FilterSheet: View {
    @Binding var selectedLanguage: String?
    @Binding var selectedUseCase: String?
    @Binding var selectedAge: String?
    @Binding var selectedGender: String?
    let languages: [String]
    let useCases: [String]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Language")) {
                    FilterChoiceRow(title: "Any", isSelected: selectedLanguage == nil) { selectedLanguage = nil }
                    ForEach(languages, id: \.self) { lang in
                        FilterChoiceRow(title: lang.uppercased(), isSelected: selectedLanguage?.lowercased() == lang.lowercased()) {
                            selectedLanguage = lang
                        }
                    }
                }
                Section(header: Text("Use case")) {
                    FilterChoiceRow(title: "Any", isSelected: selectedUseCase == nil) { selectedUseCase = nil }
                    ForEach(useCases, id: \.self) { use in
                        FilterChoiceRow(title: use.replacingOccurrences(of: "_", with: " ").capitalized, isSelected: selectedUseCase?.lowercased() == use.lowercased()) {
                            selectedUseCase = use
                        }
                    }
                }
                Section(header: Text("Age")) {
                    ForEach(["young","middle_aged","old"], id: \.self) { age in
                        FilterChoiceRow(title: age.replacingOccurrences(of: "_", with: " ").capitalized, isSelected: selectedAge?.lowercased() == age) {
                            selectedAge = age
                        }
                    }
                    FilterChoiceRow(title: "Any", isSelected: selectedAge == nil) { selectedAge = nil }
                }
                Section(header: Text("Gender")) {
                    ForEach(["female","male","neutral"], id: \.self) { g in
                        FilterChoiceRow(title: g.capitalized, isSelected: selectedGender?.lowercased() == g) {
                            selectedGender = g
                        }
                    }
                    FilterChoiceRow(title: "Any", isSelected: selectedGender == nil) { selectedGender = nil }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
                }
            }
        }
    }
}

private struct FilterChoiceRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected { Image(systemName: "checkmark").foregroundColor(.blue) }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
