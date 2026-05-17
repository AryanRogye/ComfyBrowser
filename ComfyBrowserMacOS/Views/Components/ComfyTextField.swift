//
//  ComfyTextField.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit
import SwiftUI

/// AppKit-backed single-line text field for places where SwiftUI focus is flaky.
///
/// SwiftUI still owns the text and focus bindings. AppKit only owns the actual
/// first-responder event stream so begin editing, text changes, and return key
/// submit are delivered through `NSTextFieldDelegate`.
///
/// Example:
///     `TopBar` binds `isFocused` to this field, and `onFocusChange(true)` opens
///     the search overlay as soon as AppKit begins editing.
struct ComfyTextField: NSViewRepresentable {
    
    var placeholder: String
    @Binding var text: String
    @Binding var isFocused: Bool
    var selectAllOnFocus: Bool = false
    var onSubmit: () -> Void
    var onFocusRequest: () -> Void = {}
    var onFocusChange: (Bool) -> Void
    var onTextChange: (String) -> Void
}

// MARK: - Build Coordinator
extension ComfyTextField {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            isFocused: $isFocused,
            selectAllOnFocus: selectAllOnFocus,
            onSubmit: onSubmit,
            onFocusRequest: onFocusRequest,
            onFocusChange: onFocusChange,
            onTextChange: onTextChange
        )
    }
}

// MARK: - Build AppKit View
extension ComfyTextField {
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = FocusReportingTextField()
        textField.delegate = context.coordinator
        textField.onMouseDown = {
            context.coordinator.requestFocus()
        }
        textField.stringValue = text
        textField.placeholderString = placeholder
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.textColor = .black
        textField.font = .systemFont(ofSize: NSFont.systemFontSize)
        textField.lineBreakMode = .byTruncatingTail
        textField.cell?.usesSingleLineMode = true
        textField.cell?.wraps = false
        textField.cell?.isScrollable = true
        
        return textField
    }
}

// MARK: - Sync AppKit State
extension ComfyTextField {
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        context.coordinator.text = $text
        context.coordinator.isFocused = $isFocused
        context.coordinator.selectAllOnFocus = selectAllOnFocus
        context.coordinator.onSubmit = onSubmit
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onFocusChange = onFocusChange
        context.coordinator.onTextChange = onTextChange
        
        if let textField = nsView as? FocusReportingTextField {
            textField.onMouseDown = {
                context.coordinator.requestFocus()
            }
        }
        
        if nsView.placeholderString != placeholder {
            nsView.placeholderString = placeholder
        }
        
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        
        context.coordinator.syncFocus(
            for: nsView,
            shouldFocus: isFocused
        )
    }
}

// MARK: - Coordinate Text Editing
extension ComfyTextField {
    
    final class Coordinator: NSObject {
        var text: Binding<String>
        var isFocused: Binding<Bool>
        var selectAllOnFocus: Bool
        var onSubmit: () -> Void
        var onFocusRequest: () -> Void
        var onFocusChange: (Bool) -> Void
        var onTextChange: (String) -> Void
        private var pendingFocusState: Bool?
        
        init(
            text: Binding<String>,
            isFocused: Binding<Bool>,
            selectAllOnFocus: Bool,
            onSubmit: @escaping () -> Void,
            onFocusRequest: @escaping () -> Void,
            onFocusChange: @escaping (Bool) -> Void,
            onTextChange: @escaping (String) -> Void
        ) {
            self.text = text
            self.isFocused = isFocused
            self.selectAllOnFocus = selectAllOnFocus
            self.onSubmit = onSubmit
            self.onFocusRequest = onFocusRequest
            self.onFocusChange = onFocusChange
            self.onTextChange = onTextChange
        }
    }
}

// MARK: - Sync First Responder
extension ComfyTextField.Coordinator {
    
    /// Applies SwiftUI focus state to the underlying AppKit text field.
    ///
    /// This runs after `updateNSView` returns because ending AppKit text editing
    /// synchronously during a SwiftUI update can trigger thread-priority
    /// inversion warnings.
    ///
    /// Example:
    ///     Setting `isFocused = false` after opening a search result schedules
    ///     the text field to resign first responder on the next main run-loop
    ///     turn instead of inside `updateNSView`.
    func syncFocus(
        for textField: NSTextField,
        shouldFocus: Bool
    ) {
        guard pendingFocusState != shouldFocus else { return }
        
        pendingFocusState = shouldFocus
        
        DispatchQueue.main.async { [weak self, weak textField] in
            guard let self, let textField else { return }
            
            self.pendingFocusState = nil
            
            guard
                self.isFocused.wrappedValue == shouldFocus,
                let window = textField.window
            else { return }
            
            let currentEditor = textField.currentEditor()
            
            if shouldFocus, window.firstResponder !== currentEditor {
                window.makeFirstResponder(textField)
                return
            }
            
            if !shouldFocus, window.firstResponder === currentEditor {
                window.makeFirstResponder(window.contentView)
            }
        }
    }
}

// MARK: - Handle Editing
extension ComfyTextField.Coordinator: NSTextFieldDelegate {
    
    /// Reports the reliable AppKit "started editing" event back to SwiftUI.
    ///
    /// Example:
    ///     The omnibar opens suggestions here instead of waiting for SwiftUI's
    ///     `.focused(...)` modifier to notice the focus transition.
    func controlTextDidBeginEditing(_ notification: Notification) {
        isFocused.wrappedValue = true
        onFocusChange(true)
        
        if selectAllOnFocus {
            selectAllText(from: notification)
        }
    }
    
    /// Keeps the SwiftUI binding current as AppKit edits the field.
    ///
    /// Example:
    ///     Typing "github" updates `search`, then `TopBar` asks the suggestion
    ///     provider for matching open tabs and history rows.
    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else { return }
        
        text.wrappedValue = textField.stringValue
        onTextChange(textField.stringValue)
    }
    
    /// Reports the reliable AppKit "ended editing" event back to SwiftUI.
    ///
    /// Example:
    ///     Clicking outside the field sets `isFocused` false, but overlay
    ///     dismissal can still be controlled separately by the parent view.
    func controlTextDidEndEditing(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.isFocused.wrappedValue = false
        }
        onFocusChange(false)
    }
}

// MARK: - Handle Commands
extension ComfyTextField.Coordinator {
    
    /// Reports direct mouse interaction even when editing is already active.
    ///
    /// Example:
    ///     If the overlay was dismissed while the text field stayed first
    ///     responder, clicking the field again reopens the overlay even though
    ///     `controlTextDidBeginEditing` will not fire a second time.
    func requestFocus() {
        isFocused.wrappedValue = true
        onFocusRequest()
    }
    
    /// Converts Return into the caller's submit action.
    ///
    /// Example:
    ///     Pressing Return in the omnibar opens the current search or URL, then
    ///     `TopBar` closes the overlay.
    func control(
        _ control: NSControl,
        textView: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool {
        guard commandSelector == #selector(NSResponder.insertNewline(_:)) else {
            return false
        }
        
        onSubmit()
        return true
    }
    
    private func selectAllText(from notification: Notification) {
        guard
            let textField = notification.object as? NSTextField,
            let editor = textField.currentEditor()
        else { return }
        
        editor.selectAll(nil)
    }
}

// MARK: - Report Mouse Focus Requests
private final class FocusReportingTextField: NSTextField {
    var onMouseDown: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        onMouseDown?()
        super.mouseDown(with: event)
    }
}

#Preview {
    @Previewable @State var text = "github"
    @Previewable @State var isFocused = false
    
    ComfyTextField(
        placeholder: "Search or enter address",
        text: $text,
        isFocused: $isFocused,
        selectAllOnFocus: true,
        onSubmit: {},
        onFocusRequest: {},
        onFocusChange: { _ in },
        onTextChange: { _ in }
    )
    .frame(width: 320, height: 32)
    .padding()
}
