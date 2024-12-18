import SwiftUI

struct TaskView: View {
    let content: String
    let date: Date
    let isDone: Bool
    let dueDate: Date?
    @State private var showingEditSheet = false
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Checkbox
            Image(systemName: isDone ? "checkmark.square.fill" : "square")
                .foregroundColor(isDone ? .gray : .primary)
                .font(.system(size: 24))
            
            HStack(alignment: .center, spacing: 4) {
                Text(content)
                    .strikethrough(isDone)
                    .foregroundColor(isDone ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .onTapGesture {
                        showingEditSheet = true
                    }
                
                Spacer()
                
                if let dueDate = dueDate {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "flag")
                                .font(.caption)
                            Text(formattedDueDate(dueDate))
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isDone ? Color.gray.opacity(0.2) : (dueDate < Date() ? Color.red.opacity(0.2) : Color.primary.opacity(0.1)))
                        .cornerRadius(6)
                        .foregroundColor(isDone ? .secondary : (dueDate < Date() ? .red : .primary))
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .sheet(isPresented: $showingEditSheet) {
            CreateView(viewModel: viewModel, existingNote: note)
        }
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) ? "MMM d" : "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    Group {
        // Full width preview
        ZStack {
            Color(hex: "FFFEFA")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Create a mock viewModel for preview
                let viewModel = NotesViewModel()
                
                // Task without due date
                let taskNoDueDate = Note(
                    content: "Simple task without due date",
                    date: Date(),
                    type: .task,
                    isDone: false
                )
                
                // Task with future due date
                let taskFutureDueDate = Note(
                    content: "Task with future due date",
                    date: Date(),
                    type: .task,
                    isDone: false,
                    dueDate: Date().addingTimeInterval(86400 * 2)
                )
                
                // Task with past due date
                let taskPastDueDate = Note(
                    content: "Task with past due date",
                    date: Date(),
                    type: .task,
                    isDone: false,
                    dueDate: Date().addingTimeInterval(-86400)
                )
                
                // Completed task with due date
                let taskCompleted = Note(
                    content: "Completed task with due date",
                    date: Date(),
                    type: .task,
                    isDone: true,
                    dueDate: Date().addingTimeInterval(86400)
                )
                
                // Display all variations
                TaskView(content: taskNoDueDate.content,
                       date: taskNoDueDate.date,
                       isDone: taskNoDueDate.isDone,
                       dueDate: taskNoDueDate.dueDate,
                       note: taskNoDueDate,
                       viewModel: viewModel)
                
                TaskView(content: taskFutureDueDate.content,
                       date: taskFutureDueDate.date,
                       isDone: taskFutureDueDate.isDone,
                       dueDate: taskFutureDueDate.dueDate,
                       note: taskFutureDueDate,
                       viewModel: viewModel)
                
                TaskView(content: taskPastDueDate.content,
                       date: taskPastDueDate.date,
                       isDone: taskPastDueDate.isDone,
                       dueDate: taskPastDueDate.dueDate,
                       note: taskPastDueDate,
                       viewModel: viewModel)
                
                TaskView(content: taskCompleted.content,
                       date: taskCompleted.date,
                       isDone: taskCompleted.isDone,
                       dueDate: taskCompleted.dueDate,
                       note: taskCompleted,
                       viewModel: viewModel)
            }
            .padding()
        }
    }
}
