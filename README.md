# KenzoTTS - ElevenLabs Text-to-Speech App

A SwiftUI iOS app that replicates the ElevenLabs text-to-speech interface, allowing users to convert text to speech using the ElevenLabs API.

## Features

- 🎤 **Text-to-Speech Conversion**: Convert any text to natural-sounding speech using ElevenLabs API
- 🎵 **Audio Player**: Built-in audio player with play/pause controls and progress tracking
- 🗣️ **Voice Selection**: Choose from available ElevenLabs voices (defaults to Brian voice)
- 🎨 **Dark UI**: Beautiful dark theme matching the ElevenLabs interface
- 📱 **iOS Native**: Built with SwiftUI for smooth iOS experience
- 🔄 **Regeneration**: Regenerate speech with the same or different settings

## Screenshots

The app replicates the ElevenLabs interface with:
- Clean text input area with word suggestions
- Voice selection with Brian voice as default
- Audio player that appears after generation
- Modern dark theme design

## Setup Instructions

### 1. Get ElevenLabs API Key

1. Sign up at [ElevenLabs.io](https://elevenlabs.io/)
2. Go to your profile settings
3. Copy your API key

### 2. Configure the App

1. Open `KenzoTTS/Config.swift`
2. Replace `"YOUR_API_KEY_HERE"` with your actual ElevenLabs API key:

```swift
static let elevenLabsAPIKey = "sk-your-actual-api-key-here"
```

### 3. Build and Run

1. Open `KenzoTTS.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the app (⌘+R)

## Usage

1. **Enter Text**: Type or paste the text you want to convert to speech
2. **Select Voice**: Tap the voice selector to choose from available voices (Brian is default)
3. **Generate**: Tap the "Generate" button to create speech
4. **Play**: Use the audio player controls to play, pause, or replay the generated speech
5. **Regenerate**: Modify the text and tap "Regenerate" for new audio

## Project Structure

```
KenzoTTS/
├── Models/
│   └── Voice.swift              # Voice model and data structures
├── Services/
│   ├── ElevenLabsService.swift  # API integration for text-to-speech
│   └── AudioPlayerService.swift # Audio playback functionality
├── Views/
│   ├── ContentView.swift        # Main app interface
│   ├── AudioPlayerView.swift    # Audio player component
│   └── VoiceSelectionView.swift # Voice selection sheet
├── Config.swift                 # Configuration file for API key
└── Assets.xcassets/            # App icons and assets
```

## Key Components

### ElevenLabsService
- Handles API communication with ElevenLabs
- Manages text-to-speech conversion
- Fetches available voices

### AudioPlayerService
- Manages audio playback using AVAudioPlayer
- Provides play/pause controls
- Tracks playback progress

### Voice Models
- Defines voice data structures
- Includes default Brian voice configuration
- Handles voice selection and settings

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- ElevenLabs API key
- Internet connection for API calls

## API Usage

The app uses ElevenLabs API endpoints:
- `GET /v1/voices` - Fetch available voices
- `POST /v1/text-to-speech/{voice_id}` - Generate speech

## Troubleshooting

### Common Issues

1. **"Please set your ElevenLabs API key"**
   - Make sure you've updated `Config.swift` with your actual API key

2. **"HTTP Error: 401"**
   - Your API key may be invalid or expired
   - Check your ElevenLabs account and regenerate the key if needed

3. **"HTTP Error: 429"**
   - You've exceeded your API rate limit
   - Wait a moment before trying again

4. **Audio not playing**
   - Check device volume and mute settings
   - Ensure the app has audio permissions

## License

This project is for educational and demonstration purposes. Make sure to comply with ElevenLabs' terms of service when using their API.

## Contributing

Feel free to submit issues and enhancement requests!
