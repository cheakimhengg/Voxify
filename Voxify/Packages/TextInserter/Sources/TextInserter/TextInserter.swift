import AppKit
import ApplicationServices

public struct FocusedTextState {
    public let value: String
    public let selectedRange: CFRange?
    public let selectedText: String?
}

public enum KeyCommand {
    case undo
    case redo
}

public protocol TextInserting: AnyObject {
    @discardableResult
    func insert(_ text: String) -> Bool
    func focusedTextState() -> FocusedTextState?
    @discardableResult
    func send(_ command: KeyCommand) -> Bool
}

public final class TextInserter: TextInserting {
    public init() {}

    @discardableResult
    public func insert(_ text: String) -> Bool {
        // Small delay to ensure the target app is ready
        Thread.sleep(forTimeInterval: 0.05)

        // Try accessibility-based insertion first
        if let focused = focusedElement() {
            // Method 1: Try setting selected text attribute
            if AXUIElementSetAttributeValue(focused, kAXSelectedTextAttribute as CFString, text as CFTypeRef) == .success {
                return true
            }

            // Method 2: Try value replacement at cursor position
            if let currentValue = valueString(from: focused),
               let selectedRange = selectedRange(from: focused) {
                let nsValue = currentValue as NSString
                let range = NSRange(location: selectedRange.location, length: selectedRange.length)
                let updated = nsValue.replacingCharacters(in: range, with: text)
                if AXUIElementSetAttributeValue(focused, kAXValueAttribute as CFString, updated as CFTypeRef) == .success {
                    let cursor = CFRange(location: selectedRange.location + text.count, length: 0)
                    setSelectedRange(cursor, in: focused)
                    return true
                }
            }
        }

        // Fallback: Use clipboard paste (most reliable)
        return pasteFallback(text)
    }

    public func focusedTextState() -> FocusedTextState? {
        guard let focused = focusedElement() else { return nil }
        let value = valueString(from: focused) ?? ""
        let range = selectedRange(from: focused)
        let selectedText: String?
        if let range, range.length > 0 {
            let nsValue = value as NSString
            let nsRange = NSRange(location: range.location, length: range.length)
            selectedText = nsValue.substring(with: nsRange)
        } else {
            selectedText = nil
        }
        return FocusedTextState(value: value, selectedRange: range, selectedText: selectedText)
    }

    @discardableResult
    public func send(_ command: KeyCommand) -> Bool {
        switch command {
        case .undo:
            return sendKeyCombo(keyCode: 0x06, modifiers: [.maskCommand])
        case .redo:
            return sendKeyCombo(keyCode: 0x06, modifiers: [.maskCommand, .maskShift])
        }
    }

    private func focusedElement() -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let focusedError = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard focusedError == .success, let focused = focusedElement else {
            return nil
        }
        return (focused as! AXUIElement)
    }

    private func valueString(from element: AXUIElement) -> String? {
        var value: AnyObject?
        guard AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value) == .success else {
            return nil
        }
        return value as? String
    }

    private func selectedRange(from element: AXUIElement) -> CFRange? {
        var value: AnyObject?
        guard AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &value) == .success else {
            return nil
        }
        let rangeValue = value as! AXValue
        guard AXValueGetType(rangeValue) == .cfRange else { return nil }
        var range = CFRange()
        AXValueGetValue(rangeValue, .cfRange, &range)
        return range
    }

    private func setSelectedRange(_ range: CFRange, in element: AXUIElement) {
        var mutableRange = range
        if let rangeValue = AXValueCreate(.cfRange, &mutableRange) {
            _ = AXUIElementSetAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, rangeValue)
        }
    }

    private func pasteFallback(_ text: String) -> Bool {
        let pasteboard = NSPasteboard.general
        let existingItems = clonePasteboardItems(pasteboard.pasteboardItems ?? [])

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Small delay before paste
        Thread.sleep(forTimeInterval: 0.02)

        let success = sendKeyCombo(keyCode: 0x09, modifiers: [.maskCommand])

        // Wait for paste to complete before restoring clipboard
        Thread.sleep(forTimeInterval: 0.1)

        // Restore original clipboard
        pasteboard.clearContents()
        if !existingItems.isEmpty {
            pasteboard.writeObjects(existingItems)
        }

        return success
    }

    private func clonePasteboardItems(_ items: [NSPasteboardItem]) -> [NSPasteboardItem] {
        items.map { item in
            let clone = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    clone.setData(data, forType: type)
                } else if let string = item.string(forType: type) {
                    clone.setString(string, forType: type)
                }
            }
            return clone
        }
    }

    private func sendKeyCombo(keyCode: CGKeyCode, modifiers: CGEventFlags) -> Bool {
        guard let source = CGEventSource(stateID: .combinedSessionState) else {
            return false
        }
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        keyDown?.flags = modifiers
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        keyUp?.flags = modifiers
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
        return true
    }
}
