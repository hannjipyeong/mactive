import Foundation
import Combine
import AppKit

public enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "Semua"
    case active = "Aktif"
    case completed = "Selesai"
    
    public var id: String { rawValue }
}

@MainActor
public final class TaskStore: ObservableObject {
    @Published public var tasks: [TaskItem] = [] {
        didSet {
            saveTasks()
        }
    }
    
    @Published public var selectedFilter: TaskFilter = .all
    @Published public var searchText: String = ""
    @Published public var showCountInMenuBar: Bool = true {
        didSet {
            UserDefaults.standard.set(showCountInMenuBar, forKey: "showCountInMenuBar")
            onCountChanged?()
        }
    }
    @Published public var playSoundOnComplete: Bool = true {
        didSet {
            UserDefaults.standard.set(playSoundOnComplete, forKey: "playSoundOnComplete")
        }
    }
    
    public var onCountChanged: (() -> Void)?
    
    private let saveFileURL: URL
    
    public init() {
        // Prepare storage location: ~/Library/Application Support/Mactive/tasks.json
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let mactiveDir = appSupport.appendingPathComponent("Mactive", isDirectory: true)
        
        if !fileManager.fileExists(atPath: mactiveDir.path) {
            try? fileManager.createDirectory(at: mactiveDir, withIntermediateDirectories: true)
        }
        
        self.saveFileURL = mactiveDir.appendingPathComponent("tasks.json")
        
        // Load preferences
        if UserDefaults.standard.object(forKey: "showCountInMenuBar") != nil {
            self.showCountInMenuBar = UserDefaults.standard.bool(forKey: "showCountInMenuBar")
        }
        if UserDefaults.standard.object(forKey: "playSoundOnComplete") != nil {
            self.playSoundOnComplete = UserDefaults.standard.bool(forKey: "playSoundOnComplete")
        }
        
        loadTasks()
    }
    
    public var filteredTasks: [TaskItem] {
        var result = tasks
        
        switch selectedFilter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { $0.title.lowercased().contains(query) }
        }
        
        // Sort: active tasks first (high priority first), then completed tasks
        return result.sorted { a, b in
            if a.isCompleted != b.isCompleted {
                return !a.isCompleted && b.isCompleted
            }
            if a.priority != b.priority {
                return a.priority == .high && b.priority != .high
            }
            return a.createdAt > b.createdAt
        }
    }
    
    public var activeCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    public var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    public var totalCount: Int {
        tasks.count
    }
    
    public func addTask(title: String, priority: TaskPriority = .normal) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newTask = TaskItem(title: trimmed, priority: priority)
        tasks.insert(newTask, at: 0)
        onCountChanged?()
    }
    
    public func toggleTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].toggle()
        
        if tasks[index].isCompleted && playSoundOnComplete {
            if !(NSSound(named: "Purr")?.play() ?? false) {
                NSSound.beep()
            }
        }
        onCountChanged?()
    }
    
    public func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        onCountChanged?()
    }
    
    public func clearCompleted() {
        tasks.removeAll { $0.isCompleted }
        onCountChanged?()
    }
    
    public func clearAll() {
        tasks.removeAll()
        onCountChanged?()
    }
    
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: saveFileURL, options: .atomic)
        } catch {
            print("Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    private func loadTasks() {
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else {
            // Seed a few friendly default tasks for first-time use
            self.tasks = [
                TaskItem(title: "Selamat datang di Mactive! ✨", isCompleted: true, priority: .normal),
                TaskItem(title: "Klik checkbox untuk menandai tugas selesai", isCompleted: false, priority: .normal),
                TaskItem(title: "Ketik di atas untuk menambah tugas baru 🚀", isCompleted: false, priority: .high)
            ]
            return
        }
        
        do {
            let data = try Data(contentsOf: saveFileURL)
            self.tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            print("Failed to load tasks: \(error.localizedDescription)")
        }
    }
}
