import Foundation

public enum TaskPriority: String, Codable, CaseIterable {
    case normal = "Biasa"
    case high = "Penting"
    
    public var icon: String {
        switch self {
        case .normal: return "circle"
        case .high: return "exclamationmark.circle.fill"
        }
    }
}

public struct TaskItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool
    public var priority: TaskPriority
    public var createdAt: Date
    public var completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        priority: TaskPriority = .normal,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
    
    public mutating func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}
