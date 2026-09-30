import Foundation

public enum TaskAction: String, Codable, CaseIterable {
    case created = "Dibuat"
    case completed = "Selesai"
    case reopened = "Dibuka Kembali"
    case deleted = "Dihapus"
    
    public var icon: String {
        switch self {
        case .created: return "plus.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .reopened: return "arrow.uturn.backward.circle.fill"
        case .deleted: return "trash.fill"
        }
    }
}

public struct TaskHistoryItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var taskId: UUID?
    public var taskTitle: String
    public var action: TaskAction
    public var timestamp: Date
    public var note: String?
    
    public init(
        id: UUID = UUID(),
        taskId: UUID? = nil,
        taskTitle: String,
        action: TaskAction,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.action = action
        self.timestamp = timestamp
        self.note = note
    }
}
