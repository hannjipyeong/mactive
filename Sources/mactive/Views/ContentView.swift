import SwiftUI

public struct ContentView: View {
    @ObservedObject var store: TaskStore
    @ObservedObject private var launchAtLogin = LaunchAtLogin.shared
    @State private var newTaskTitle: String = ""
    @State private var selectedPriority: TaskPriority = .normal
    @FocusState private var isInputFocused: Bool
    
    public init(store: TaskStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            headerView
            
            Divider()
            
            // MARK: - Input Bar
            inputSection
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            
            // MARK: - Filter Pills
            filterSection
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            
            Divider()
            
            // MARK: - Task List
            taskListSection
            
            Divider()
            
            // MARK: - Footer
            footerView
        }
        .frame(width: 360, height: 460)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputFocused = true
            }
        }
        .onExitCommand {
            if !newTaskTitle.isEmpty {
                newTaskTitle = ""
            } else {
                NSApplication.shared.keyWindow?.close()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Image(systemName: "checklist.checked")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Mactive")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("\(store.activeCount) tugas menunggu")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action Menu
            Menu {
                Toggle("Tampilkan Jumlah di Menu Bar", isOn: $store.showCountInMenuBar)
                Toggle("Suara saat Selesai", isOn: $store.playSoundOnComplete)
                Toggle("Jalankan saat Login Mac", isOn: Binding(
                    get: { launchAtLogin.isEnabled },
                    set: { _ in launchAtLogin.toggle() }
                ))
                
                Divider()
                
                Button(role: .none, action: {
                    withAnimation {
                        store.clearCompleted()
                    }
                }) {
                    Label("Hapus yang Sudah Selesai", systemImage: "trash")
                }
                .disabled(store.completedCount == 0)
                
                Button(role: .destructive, action: {
                    withAnimation {
                        store.clearAll()
                    }
                }) {
                    Label("Hapus Semua Tugas", systemImage: "trash.fill")
                }
                .disabled(store.totalCount == 0)
                
                Divider()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Label("Keluar dari Mactive", systemImage: "power")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                TextField("Mau ngerjain apa? (Tekan Enter)", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($isInputFocused)
                    .onSubmit {
                        submitNewTask()
                    }
                
                if !newTaskTitle.isEmpty {
                    Button(action: {
                        newTaskTitle = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Priority switch
                Button(action: {
                    selectedPriority = (selectedPriority == .normal) ? .high : .normal
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: selectedPriority == .high ? "exclamationmark.circle.fill" : "flag")
                            .font(.system(size: 11))
                        Text(selectedPriority.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(selectedPriority == .high ? Color.red.opacity(0.15) : Color.primary.opacity(0.06))
                    .foregroundColor(selectedPriority == .high ? .red : .secondary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .help("Ubah prioritas (Biasa / Penting)")
                
                // Add button
                Button(action: submitNewTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 17))
                        .foregroundColor(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary.opacity(0.4) : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .help("Tambah tugas")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        HStack(spacing: 6) {
            ForEach(TaskFilter.allCases) { filter in
                let count: Int = {
                    switch filter {
                    case .all: return store.totalCount
                    case .active: return store.activeCount
                    case .completed: return store.completedCount
                    }
                }()
                
                let isSelected = store.selectedFilter == filter
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        store.selectedFilter = filter
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(filter.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                        
                        Text("\(count)")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(isSelected ? Color.white.opacity(0.25) : Color.primary.opacity(0.06))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? Color.accentColor : Color.clear)
                    )
                    .foregroundColor(isSelected ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Task List Section
    private var taskListSection: some View {
        ScrollView {
            if store.filteredTasks.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, minHeight: 220)
            } else {
                LazyVStack(spacing: 2) {
                    ForEach(store.filteredTasks) { task in
                        TaskRowView(
                            task: task,
                            onToggle: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    store.toggleTask(task)
                                }
                            },
                            onDelete: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    store.deleteTask(id: task.id)
                                }
                            }
                        )
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text(emptyStateText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private var emptyStateIcon: String {
        switch store.selectedFilter {
        case .all:
            return "checklist"
        case .active:
            return "sparkles"
        case .completed:
            return "tray"
        }
    }
    
    private var emptyStateText: String {
        switch store.selectedFilter {
        case .all:
            return "Belum ada tugas.\nKetik di atas untuk menambahkan tugas barumu!"
        case .active:
            return "Semua tugas aktif sudah selesai!\nKerja bagus, santai sejenak ✨"
        case .completed:
            return "Belum ada tugas yang diselesaikan."
        }
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        HStack {
            if store.totalCount > 0 {
                let progress = Double(store.completedCount) / Double(store.totalCount)
                
                HStack(spacing: 6) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .frame(width: 80)
                    
                    Text("\(Int(progress * 100))% selesai")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Mactive • Menu Bar To-Do")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if store.completedCount > 0 {
                Button(action: {
                    withAnimation {
                        store.clearCompleted()
                    }
                }) {
                    Text("Bersihkan Selesai")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Hapus semua tugas yang sudah selesai")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.02))
    }
    
    // MARK: - Actions
    private func submitNewTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            store.addTask(title: trimmed, priority: selectedPriority)
            newTaskTitle = ""
            selectedPriority = .normal
        }
    }
}

// Helper for native translucent macOS popover material
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
