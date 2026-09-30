import SwiftUI

public struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering: Bool = false
    
    public init(
        task: TaskItem,
        onToggle: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.task = task
        self.onToggle = onToggle
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Checkbox button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(task.isCompleted ? .green : .secondary.opacity(0.7))
            }
            .buttonStyle(.plain)
            .help(task.isCompleted ? "Tandai belum selesai" : "Tandai selesai")
            
            // Content & metadata
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(task.title)
                        .font(.system(size: 13, weight: task.isCompleted ? .regular : .medium))
                        .strikethrough(task.isCompleted, color: .secondary)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .lineLimit(2)
                    
                    if task.priority == .high && !task.isCompleted {
                        Text("Penting")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }
                
                Text(formattedDate(task.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            Spacer()
            
            // Delete button (revealed on hover or always subtle)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .opacity(isHovering ? 1.0 : 0.0)
            }
            .buttonStyle(.plain)
            .help("Hapus tugas")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color.primary.opacity(0.04) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Hari ini, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Kemarin"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
    }
}
