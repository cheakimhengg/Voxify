import Foundation

/// Centralized localization helper for English and Khmer
enum L10n {
    /// Get localized string based on current interface language
    static func string(_ key: LocalizedKey, language: String) -> String {
        let isKhmer = language == "Khmer"
        return isKhmer ? key.khmer : key.english
    }
}

/// All localized strings in the app
enum LocalizedKey {
    // Navigation / Sidebar
    case home
    case settings
    case history
    case dictionary
    case information
    case account
    case personalization

    // Home Dashboard
    case welcomeBack
    case todayStats
    case wordsToday
    case sessionsToday
    case minutesToday
    case weeklyActivity
    case recentDictations
    case noRecentDictations
    case quickActions
    case startDictation
    case viewHistory
    case openSettings

    // Recording Popup
    case recording
    case processing
    case holdMode
    case freeHandMode
    case releaseToStop
    case pressAgainToStop

    // Settings
    case keyboardShortcuts
    case holdToTalk
    case holdToTalkDesc
    case handsFreeMode
    case handsFreeModeDesc
    case readAloud
    case readAloudDesc
    case language
    case interfaceLanguage
    case interfaceLanguageDesc
    case speechRecognition
    case speechRecognitionDesc
    case audio
    case beepOnStartStop
    case beepOnStartStopDesc
    case showWaveform
    case showWaveformDesc
    case pauseThreshold
    case pauseThresholdDesc
    case seconds
    case textToSpeech
    case enableTTS
    case enableTTSDesc
    case speechRate
    case speechRateDesc
    case reset
    case resetAllSettings
    case resetAllSettingsDesc
    case resetConfirmTitle
    case resetConfirmMessage
    case cancel

    // Account
    case username
    case usernameDesc
    case version
    case versionDesc
    case data
    case dataDesc
    case privateLabel
    case privacyNote
    case edit
    case save

    // Personalization
    case aiPolishing
    case autoRemoveFillers
    case autoRemoveFillersDesc
    case repetitionDetection
    case repetitionDetectionDesc
    case grammarCorrection
    case grammarCorrectionDesc
    case autoFormatting
    case autoFormattingDesc
    case midSentenceCorrection
    case midSentenceCorrectionDesc
    case tone
    case contextAwareTone
    case contextAwareToneDesc
    case defaultTone
    case defaultToneDesc
    case privacy
    case saveHistory
    case saveHistoryDesc
    case privacyMode
    case privacyModeDesc

    // History
    case searchHistory
    case noHistory
    case clearAll

    // Information
    case about
    case helpCenter
    case releaseNotes

    // Common
    case clickToSet
    case pressAnyKey

    var english: String {
        switch self {
        // Navigation
        case .home: return "Home"
        case .settings: return "Settings"
        case .history: return "History"
        case .dictionary: return "Dictionary"
        case .information: return "Information"
        case .account: return "Account"
        case .personalization: return "Personalization"

        // Home Dashboard
        case .welcomeBack: return "Welcome back"
        case .todayStats: return "Today's Stats"
        case .wordsToday: return "Words Today"
        case .sessionsToday: return "Sessions"
        case .minutesToday: return "Minutes"
        case .weeklyActivity: return "Weekly Activity"
        case .recentDictations: return "Recent Dictations"
        case .noRecentDictations: return "No recent dictations"
        case .quickActions: return "Quick Actions"
        case .startDictation: return "Start Dictation"
        case .viewHistory: return "View History"
        case .openSettings: return "Open Settings"

        // Recording
        case .recording: return "Recording"
        case .processing: return "Processing"
        case .holdMode: return "Hold"
        case .freeHandMode: return "Free Hand"
        case .releaseToStop: return "Release to stop"
        case .pressAgainToStop: return "Press again to stop"

        // Settings
        case .keyboardShortcuts: return "Keyboard shortcuts"
        case .holdToTalk: return "Hold to Talk"
        case .holdToTalkDesc: return "Hold down to speak. Release to insert text."
        case .handsFreeMode: return "Hands-free Mode"
        case .handsFreeModeDesc: return "Press once to start speaking. Press again to stop."
        case .readAloud: return "Read Aloud (TTS)"
        case .readAloudDesc: return "Read the last dictated or selected text aloud."
        case .language: return "Language"
        case .interfaceLanguage: return "Interface language"
        case .interfaceLanguageDesc: return "Choose the language for the app interface."
        case .speechRecognition: return "Speech recognition hint"
        case .speechRecognitionDesc: return "Language hint for better accuracy."
        case .audio: return "Audio"
        case .beepOnStartStop: return "Beep on start/stop"
        case .beepOnStartStopDesc: return "Play a sound when dictation starts and stops."
        case .showWaveform: return "Show audio waveform"
        case .showWaveformDesc: return "Display animated waveform during recording."
        case .pauseThreshold: return "Pause threshold"
        case .pauseThresholdDesc: return "Seconds of silence before auto-stopping."
        case .seconds: return "sec"
        case .textToSpeech: return "Text-to-Speech"
        case .enableTTS: return "Enable TTS"
        case .enableTTSDesc: return "Allow reading text aloud with keyboard shortcut."
        case .speechRate: return "Speech rate"
        case .speechRateDesc: return "How fast the text is read."
        case .reset: return "Reset"
        case .resetAllSettings: return "Reset all settings"
        case .resetAllSettingsDesc: return "Restore all settings to their default values."
        case .resetConfirmTitle: return "Reset Settings?"
        case .resetConfirmMessage: return "This will reset all settings to their default values."
        case .cancel: return "Cancel"

        // Account
        case .username: return "Username"
        case .usernameDesc: return "Your display name in the app"
        case .version: return "Version"
        case .versionDesc: return "Current app version"
        case .data: return "Data"
        case .dataDesc: return "Your dictation data is stored locally"
        case .privateLabel: return "Private"
        case .privacyNote: return "All your data stays on your device. Voxify is free and open-source."
        case .edit: return "Edit"
        case .save: return "Save"

        // Personalization
        case .aiPolishing: return "AI Polishing"
        case .autoRemoveFillers: return "Auto-remove fillers"
        case .autoRemoveFillersDesc: return "Remove \"um\", \"uh\", and similar filler words."
        case .repetitionDetection: return "Repetition detection"
        case .repetitionDetectionDesc: return "Remove repeated words and phrases."
        case .grammarCorrection: return "Grammar correction"
        case .grammarCorrectionDesc: return "Fix grammatical errors automatically."
        case .autoFormatting: return "Auto-formatting"
        case .autoFormattingDesc: return "Format lists, bullets, and paragraphs."
        case .midSentenceCorrection: return "Mid-sentence correction"
        case .midSentenceCorrectionDesc: return "Detect \"no wait\" or \"I mean\" and keep only your intent."
        case .tone: return "Tone"
        case .contextAwareTone: return "Context-aware tone"
        case .contextAwareToneDesc: return "Automatically adjust tone based on the active app."
        case .defaultTone: return "Default tone"
        case .defaultToneDesc: return "Used when context-aware is disabled."
        case .privacy: return "Privacy"
        case .saveHistory: return "Save dictation history"
        case .saveHistoryDesc: return "Store your dictations for later review."
        case .privacyMode: return "Privacy mode"
        case .privacyModeDesc: return "When enabled, dictations are not saved."

        // History
        case .searchHistory: return "Search history..."
        case .noHistory: return "No dictation history"
        case .clearAll: return "Clear All"

        // Information
        case .about: return "About Voxify"
        case .helpCenter: return "Help center"
        case .releaseNotes: return "Release notes"

        // Common
        case .clickToSet: return "Click to set"
        case .pressAnyKey: return "Press any key..."
        }
    }

    var khmer: String {
        switch self {
        // Navigation
        case .home: return "ទំព័រដើម"
        case .settings: return "ការកំណត់"
        case .history: return "ប្រវត្តិ"
        case .dictionary: return "វចនានុក្រម"
        case .information: return "ព័ត៌មាន"
        case .account: return "គណនី"
        case .personalization: return "ការកំណត់ផ្ទាល់ខ្លួន"

        // Home Dashboard
        case .welcomeBack: return "សូមស្វាគមន៍"
        case .todayStats: return "ស្ថិតិថ្ងៃនេះ"
        case .wordsToday: return "ពាក្យថ្ងៃនេះ"
        case .sessionsToday: return "វគ្គ"
        case .minutesToday: return "នាទី"
        case .weeklyActivity: return "សកម្មភាពប្រចាំសប្តាហ៍"
        case .recentDictations: return "ការសរសេរថ្មីៗ"
        case .noRecentDictations: return "មិនមានការសរសេរថ្មីៗ"
        case .quickActions: return "សកម្មភាពរហ័ស"
        case .startDictation: return "ចាប់ផ្តើមសរសេរ"
        case .viewHistory: return "មើលប្រវត្តិ"
        case .openSettings: return "បើកការកំណត់"

        // Recording
        case .recording: return "កំពុងថត"
        case .processing: return "កំពុងដំណើរការ"
        case .holdMode: return "សង្កត់"
        case .freeHandMode: return "ដោយស្វ័យប្រវត្តិ"
        case .releaseToStop: return "លែងដើម្បីបញ្ឈប់"
        case .pressAgainToStop: return "ចុចម្តងទៀតដើម្បីបញ្ឈប់"

        // Settings
        case .keyboardShortcuts: return "ផ្លូវកាត់ក្តារចុច"
        case .holdToTalk: return "សង្កត់ដើម្បីនិយាយ"
        case .holdToTalkDesc: return "សង្កត់ដើម្បីនិយាយ។ លែងដើម្បីបញ្ចូលអត្ថបទ។"
        case .handsFreeMode: return "របៀបដោយស្វ័យប្រវត្តិ"
        case .handsFreeModeDesc: return "ចុចម្តងដើម្បីចាប់ផ្តើម។ ចុចម្តងទៀតដើម្បីបញ្ឈប់។"
        case .readAloud: return "អានឮ (TTS)"
        case .readAloudDesc: return "អានអត្ថបទចុងក្រោយឬអត្ថបទដែលបានជ្រើសរើស។"
        case .language: return "ភាសា"
        case .interfaceLanguage: return "ភាសាចំណុចប្រទាក់"
        case .interfaceLanguageDesc: return "ជ្រើសរើសភាសាសម្រាប់កម្មវិធី។"
        case .speechRecognition: return "ការសម្គាល់សម្រាប់សំឡេង"
        case .speechRecognitionDesc: return "ភាសាសម្រាប់ការសម្គាល់សំឡេង។"
        case .audio: return "សំឡេង"
        case .beepOnStartStop: return "សំឡេងបើក/បិទ"
        case .beepOnStartStopDesc: return "លេងសំឡេងនៅពេលចាប់ផ្តើម/បញ្ឈប់។"
        case .showWaveform: return "បង្ហាញរលកសំឡេង"
        case .showWaveformDesc: return "បង្ហាញរលកសំឡេងនៅពេលថត។"
        case .pauseThreshold: return "រយៈពេលផ្អាក"
        case .pauseThresholdDesc: return "វិនាទីនៃភាពស្ងាត់មុនពេលបញ្ឈប់។"
        case .seconds: return "វិនាទី"
        case .textToSpeech: return "អានជាសំឡេង"
        case .enableTTS: return "បើក TTS"
        case .enableTTSDesc: return "អនុញ្ញាតឱ្យអានជាសំឡេង។"
        case .speechRate: return "ល្បឿនអាន"
        case .speechRateDesc: return "ល្បឿនក្នុងការអានអត្ថបទ។"
        case .reset: return "កំណត់ឡើងវិញ"
        case .resetAllSettings: return "កំណត់ការកំណត់ទាំងអស់ឡើងវិញ"
        case .resetAllSettingsDesc: return "ស្តារការកំណត់ទាំងអស់ទៅតម្លៃដើម។"
        case .resetConfirmTitle: return "កំណត់ការកំណត់ឡើងវិញ?"
        case .resetConfirmMessage: return "នេះនឹងកំណត់ការកំណត់ទាំងអស់ទៅតម្លៃដើម។"
        case .cancel: return "បោះបង់"

        // Account
        case .username: return "ឈ្មោះអ្នកប្រើប្រាស់"
        case .usernameDesc: return "ឈ្មោះបង្ហាញរបស់អ្នកក្នុងកម្មវិធី"
        case .version: return "កំណែ"
        case .versionDesc: return "កំណែកម្មវិធីបច្ចុប្បន្ន"
        case .data: return "ទិន្នន័យ"
        case .dataDesc: return "ទិន្នន័យរបស់អ្នកត្រូវបានរក្សាទុកក្នុងម៉ាស៊ីន"
        case .privateLabel: return "ឯកជន"
        case .privacyNote: return "ទិន្នន័យទាំងអស់រក្សាទុកក្នុងឧបករណ៍របស់អ្នក។ Voxify គឺឥតគិតថ្លៃ។"
        case .edit: return "កែសម្រួល"
        case .save: return "រក្សាទុក"

        // Personalization
        case .aiPolishing: return "ការកែលម្អ AI"
        case .autoRemoveFillers: return "ដកពាក្យបំពេញដោយស្វ័យប្រវត្តិ"
        case .autoRemoveFillersDesc: return "ដកពាក្យដូចជា \"អឺម\" \"អា\" ។"
        case .repetitionDetection: return "រកឃើញការធ្វើម្តងទៀត"
        case .repetitionDetectionDesc: return "ដកពាក្យនិងឃ្លាដែលធ្វើម្តងទៀត។"
        case .grammarCorrection: return "កែវេយ្យាករណ៍"
        case .grammarCorrectionDesc: return "កែកំហុសវេយ្យាករណ៍ដោយស្វ័យប្រវត្តិ។"
        case .autoFormatting: return "ទម្រង់ស្វ័យប្រវត្តិ"
        case .autoFormattingDesc: return "ទម្រង់បញ្ជី ចំណុច និងកថាខណ្ឌ។"
        case .midSentenceCorrection: return "កែពាក្យកណ្តាលប្រយោគ"
        case .midSentenceCorrectionDesc: return "រកឃើញ \"ចាំ\" ឬ \"ខ្ញុំចង់និយាយ\" ។"
        case .tone: return "សម្លេង"
        case .contextAwareTone: return "សម្លេងតាមបរិបទ"
        case .contextAwareToneDesc: return "កែសម្រួលសម្លេងដោយស្វ័យប្រវត្តិ។"
        case .defaultTone: return "សម្លេងលំនាំដើម"
        case .defaultToneDesc: return "ប្រើនៅពេលបរិបទត្រូវបានបិទ។"
        case .privacy: return "ឯកជនភាព"
        case .saveHistory: return "រក្សាទុកប្រវត្តិ"
        case .saveHistoryDesc: return "រក្សាទុកការសរសេររបស់អ្នកសម្រាប់ពិនិត្យ។"
        case .privacyMode: return "របៀបឯកជន"
        case .privacyModeDesc: return "នៅពេលបើក ការសរសេរមិនត្រូវបានរក្សាទុក។"

        // History
        case .searchHistory: return "ស្វែងរកប្រវត្តិ..."
        case .noHistory: return "មិនមានប្រវត្តិ"
        case .clearAll: return "សម្អាតទាំងអស់"

        // Information
        case .about: return "អំពី Voxify"
        case .helpCenter: return "មជ្ឈមណ្ឌលជំនួយ"
        case .releaseNotes: return "កំណត់ចំណាំកំណែ"

        // Common
        case .clickToSet: return "ចុចដើម្បីកំណត់"
        case .pressAnyKey: return "ចុចគ្រាប់ចុចណាមួយ..."
        }
    }
}
