import AVFoundation

public struct PCMChunk {
    public let sequence: Int
    public let data: Data
    public let sampleRate: Double
    public let rms: Float

    public init(sequence: Int, data: Data, sampleRate: Double, rms: Float) {
        self.sequence = sequence
        self.data = data
        self.sampleRate = sampleRate
        self.rms = rms
    }
}

public protocol AudioCapturing: AnyObject {
    var onPCMChunk: ((PCMChunk) -> Void)? { get set }
    func start() throws
    func stop()
}

public final class AudioCapture: AudioCapturing {
    public var onPCMChunk: ((PCMChunk) -> Void)?

    private let engine = AVAudioEngine()
    private var sequence = 0

    public init() {}

    public func start() throws {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self else { return }
            guard let channelData = buffer.floatChannelData?.pointee else { return }

            let frameCount = Int(buffer.frameLength)
            let data = Data(bytes: channelData, count: frameCount * MemoryLayout<Float>.size)
            let rms = Self.rmsValue(for: channelData, frameCount: frameCount)
            let chunk = PCMChunk(sequence: sequence, data: data, sampleRate: format.sampleRate, rms: rms)
            sequence += 1
            onPCMChunk?(chunk)
        }

        engine.prepare()
        try engine.start()
    }

    public func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }

    private static func rmsValue(for data: UnsafePointer<Float>, frameCount: Int) -> Float {
        guard frameCount > 0 else { return 0 }
        var sum: Float = 0
        for index in 0..<frameCount {
            let value = data[index]
            sum += value * value
        }
        return sqrt(sum / Float(frameCount))
    }
}
