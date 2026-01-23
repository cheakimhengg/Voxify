# Voxify Voice Dictation Quickstart

## Prerequisites

- macOS 13+
- Xcode 15+ (Swift 5.9+)
- Apple Silicon Mac recommended

## Setup

1. Clone the repo and open the project:
   - Open `Voxify/Voxify.xcodeproj` in Xcode.
2. Ensure microphone permissions are granted when prompted.
3. Enable Accessibility permissions for text insertion when prompted.

## Run

- In Xcode, select the Voxify scheme and run.
- Use the menu bar icon or global hotkey to start dictation.
- Live preview appears only while dictation is active.

## Tests

- Run unit tests: Xcode Test action
- Run integration tests: Xcode Test action (Integration target)

## Local Data

- Settings and personal dictionary are stored locally in UserDefaults and JSON
  files.
- API keys (if used) are stored locally and never transmitted without consent.

## Troubleshooting

- If text insertion fails, re-check Accessibility permissions.
- If dictation fails to start, verify microphone access in System Settings.
