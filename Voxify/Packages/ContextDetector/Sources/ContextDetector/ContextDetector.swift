import AppKit

public struct ActiveAppDetector {
    public init() {}

    public func currentBundleIdentifier() -> String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }
}
