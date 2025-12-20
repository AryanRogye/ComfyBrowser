//
//  LocalShortcutsRecorder.swift
//  LocalShortcuts
//
//  Created by Aryan Rogye on 12/4/25.
//

import AppKit
import SwiftUI
import Carbon.HIToolbox

extension LocalShortcuts {
    public struct LocalShortcutsRecorder: NSViewRepresentable {
        
        let name : Name

        public init(for name: Name) {
            self.name = name
        }
        
        
        public func makeNSView(context: Context) -> LocalShortcutRecorderSearch {
            return LocalShortcutRecorderSearch(for: name)
        }
        
        public func updateNSView(_ nsView: LocalShortcuts.LocalShortcutRecorderSearch, context: Context) {
            
        }
    }
    
    public final class LocalShortcutRecorderSearch: NSSearchField, NSSearchFieldDelegate {
        
        private let minimumWidth = 130.0
        
        private let name: LocalShortcuts.Name
        private var eventMonitor: Any?
        
        public required init(
            for name: LocalShortcuts.Name
        ) {
            self.name = name
            
            super.init(frame: NSRect(x: 0, y: 0, width: minimumWidth, height: 24))
            
            delegate = self
            placeholderString = "Press shortcut"
            alignment = .center
            (cell as? NSSearchFieldCell)?.searchButtonCell = nil
            
            wantsLayer = true
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            updateStringValue()
        }
        
        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func updateStringValue() {
            if let shortcut = LocalShortcuts.Name.shortcuts[name] {
                stringValue = "\(shortcut.modifiers()) \(shortcut.keyValues())"
            } else {
                stringValue = ""
            }
        }
        
        // MARK: - Recording
        
        override public func becomeFirstResponder() -> Bool {
            let ok = super.becomeFirstResponder()
            guard ok else { return false }
            
            placeholderString = "Press shortcut…"
            startRecording()
            return true
        }
        
        override public func resignFirstResponder() -> Bool {
            stopRecording()
            return super.resignFirstResponder()
        }
        
        private func startRecording() {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                self?.handleKeyEvent(event)
                return nil
            }
        }
        
        private func stopRecording() {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
            placeholderString = "Press shortcut"
        }
        
        private func handleKeyEvent(_ event: NSEvent) {
            // Escape cancels
            if event.keyCode == kVK_Escape {
                window?.makeFirstResponder(nil)
                return
            }
            
            // Build your LocalShortcuts.Shortcut from the NSEvent
            let shortcut = LocalShortcuts.Shortcut.getShortcut(event: event)
            
            // Store it in your bindings
            LocalShortcuts.Name.shortcuts[name] = shortcut
            
            // Update UI
            stringValue = "\(shortcut)"
            window?.makeFirstResponder(nil)
        }
    }}
