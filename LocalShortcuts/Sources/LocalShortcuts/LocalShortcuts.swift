import AppKit

public enum LocalShortcuts {
    public struct Name: Hashable, Codable {
        
        public typealias Handler = () -> Void
        typealias LocalMonitor = Any
        public let rawValue: String
        public let defaultShortcut: Shortcut

        @MainActor internal static var monitor: LocalMonitor?
        
        @MainActor internal static var shortcuts: [Name: Shortcut] = [:]
        @MainActor internal static var handlers:  [Name: Handler] = [:]
        
        /// Registers with null
        @MainActor public init(_ rawValue: String, _ shortcut: Shortcut) {
            self.rawValue = rawValue
            self.defaultShortcut = shortcut
            Self.shortcuts[self] = shortcut
        }
        
        @MainActor public static func onKeyDown(
            for name: Name,
            completion: @escaping Handler
        ) {
            handlers[name] = completion
            startMonitorIfNeeded()
        }
        
        @MainActor private static func startMonitorIfNeeded() {
            guard Name.monitor == nil else { return }
            
            Name.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                let handled = handle(event: event)
                // Returning nil consumes the event so it doesn't bounce back from remote views.
                return handled ? nil : event
            }
        }
        
        @MainActor private static var lastShortcutHandled: (shortcut: Shortcut, timestamp: TimeInterval)?
        
        @MainActor @discardableResult
        private static func handle(event: NSEvent) -> Bool {
            guard !event.isARepeat else { return false }
            
            let eventShortcut = Shortcut.getShortcut(event: event)
            guard let (name, _) = shortcuts.first(where: { $0.value == eventShortcut }),
                  let handler = handlers[name] else { return false }
            
            // Drop near-simultaneous duplicates for the same shortcut (e.g. from remote views)
            let now = ProcessInfo.processInfo.systemUptime
            if let last = lastShortcutHandled,
               last.shortcut == eventShortcut,
               (now - last.timestamp) < 0.05 {
                return true
            }
            lastShortcutHandled = (eventShortcut, now)
            handler()
            return true
        }
    }
    
    public struct Shortcut: Codable, Hashable {
        let modifier: [Modifier]
        let keys: [Key]
        
        public init(modifier: [Modifier], keys: [Key]) {
            self.modifier = modifier
            self.keys = keys
        }
        
        @MainActor public static func getShortcut(event: NSEvent) -> Shortcut {
            let modifiers = LocalShortcuts.Modifier.activeModifiers(from: event)
            let keys = LocalShortcuts.Key.activeKeys(event: event)
            
            return Shortcut(modifier: modifiers, keys: keys)
        }
        
        @MainActor
        public func modifiers() -> String {
            var str : String = ""
            for mod in modifier {
                str.append(mod.rawValue)
            }
            return str
        }
        
        @MainActor
        public func keyValues() -> String {
            var str : String = "";
            for key in keys {
                str.append("\(key.rawValue)")
            }
            return str
        }
    }
}
