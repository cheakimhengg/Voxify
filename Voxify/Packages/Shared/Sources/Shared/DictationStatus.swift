public enum DictationStatus: String, Codable {
    case idle
    case listening
    case processing
    case paused
    case completed
    case error
}
