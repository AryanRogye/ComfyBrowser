//
//  SidebarDragDropCoordinator.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/20/26.
//

import AppKit

final class SidebarDragDropCoordinator {
    static let dragType = NSPasteboard.PasteboardType("com.comfybrowser.sidebar-item")
    var getItem: ((IndexPath) -> (SidebarSectionKind, SidebarNode)?)

    init(getItem: @escaping (IndexPath) -> ((SidebarSectionKind, SidebarNode)?)) {
        self.getItem = getItem
    }


}

// MARK: - Public API's
extension SidebarDragDropCoordinator {
    public func dragItem(at indexPath: IndexPath) -> DragItem? {
        guard let (_, node) = getItem(indexPath) else { return nil }

        switch node {
        case .tab(let tab):
            return DragItem(kind: .tab, id: tab.id)
        case .folder(let folder):
            return DragItem(kind: .folder, id: folder.id)
        }
    }

    public func draggedItem(from info: NSDraggingInfo) -> DragItem? {
        guard let value = info.draggingPasteboard.string(forType: Self.dragType) else {
            return nil
        }

        return DragItem(pasteboardValue: value)
    }
}

// MARK: - Models
extension SidebarDragDropCoordinator {
    public enum DragKind: String { case tab, folder }

    public struct DragItem {
        var kind: DragKind
        var id: UUID

        var pasteboardValue: String { "\(kind.rawValue):\(id.uuidString)" }

        public init(
            kind: DragKind,
            id: UUID
        ) {
            self.kind = kind
            self.id = id
        }

        init?(pasteboardValue: String) {
            let parts = pasteboardValue.split(separator: ":")
            guard parts.count == 2,
                  let kind = DragKind(rawValue: String(parts[0])),
                  let id = UUID(uuidString: String(parts[1])) else { return nil }
            self.kind = kind
            self.id = id
        }
    }
}
