import ApplicationServices

public protocol TextInserting: AnyObject {
    @discardableResult
    func insert(_ text: String) -> Bool
}

public final class TextInserter: TextInserting {
    public init() {}

    @discardableResult
    public func insert(_ text: String) -> Bool {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let focusedError = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard focusedError == .success, let focused = focusedElement else {
            return false
        }

        let setError = AXUIElementSetAttributeValue(focused as! AXUIElement, kAXValueAttribute as CFString, text as CFTypeRef)
        return setError == .success
    }
}
