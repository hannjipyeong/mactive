import SwiftUI

public struct HistoryView: View {
    @ObservedObject var store: TaskStore
    @State private var filterAction: TaskAction? = nil
    
    public init(store: TaskStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search & Action Filters
            VStack(spacing: 8) {
                // Search field
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    TextField("Cari di log riwayat...", text: $store.historySearchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                    
                    if !store.historySearchText.isEmpty {
                        Button(action: {
                            store.historySearchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )
                
                // Filter by action pill buttons
                HStack(spacing: 4) {
                    filterPill(title: "Semua", action: nil)
                    ForEach(TaskAction.allCases, id: \.self) { action in
                        filterPill(title: action.rawValue, action: action)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            Divider()
            
            // History List
            let logs = displayedLogs
            if logs.isEmpty {
                emptyHistoryView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(logs) { item in
                            historyRow(for: item)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                Text("\(logs.count) aktivitas tercatat")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !store.historyLogs.isEmpty {
                    Button(action: {
                        withAnimation {
                            store.clearHistory()
                        }
                    }) {
                        Text("Bersihkan Riwayat")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.02))
        }
    }
    
    private var displayedLogs: [TaskHistoryItem] {
        var logs = store.filteredHistory
        if let filterAction = filterAction {
            logs = logs.filter { $0.action == filterAction }
        }
        return logs
    }
    
    private func filterPill(title: String, action: TaskAction?) -> some View {
        let isSelected = (filterAction == action)
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.12)) {
                filterAction = action
            }
        }) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(isSelected ? Color.accentColor : Color.primary.opacity(0.05))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func historyRow(for item: TaskHistoryItem) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Action icon badge
            ZStack {
                Circle()
                    .fill(badgeColor(for: item.action).opacity(0.15))
                    .frame(width: 26, height: 26)
                
                Image(systemName: item.action.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(badgeColor(for: item.action))
            }
            .padding(.top, 2)
            
            // Detail
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.action.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeColor(for: item.action))
                    
                    Text("•")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Text(formatTimestamp(item.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Text(item.taskTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let note = item.note {
                    Text(note)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.02))
        )
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 30))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Tidak ada riwayat aktivitas")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Setiap kali kamu membuat, menyelesaikan, atau menghapus tugas, catatannya akan otomatis muncul di sini.")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
    
    private func badgeColor(for action: TaskAction) -> Color {
        switch action {
        case .created:
            return .blue
        case .completed:
            return .green
        case .reopened:
            return .orange
        case .deleted:
            return .red
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let timeStr = timeFormatter.string(from: date)
        
        if calendar.isDateInToday(date) {
            return "Hari ini, \(timeStr)"
        } else if calendar.isDateInYesterday(date) {
            return "Kemarin, \(timeStr)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM, HH:mm"
            return dateFormatter.string(from: date)
        }
    }
}
