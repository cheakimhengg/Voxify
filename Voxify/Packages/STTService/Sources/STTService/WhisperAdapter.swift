import AudioEngine

public protocol WhisperTranscribing {
    func transcribe(chunk: PCMChunk) -> String
}

public final class WhisperAdapter: WhisperTranscribing {
    public init() {}

    public func transcribe(chunk: PCMChunk) -> String {
        "chunk-\(chunk.sequence)"
    }
}
