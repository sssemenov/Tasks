import SwiftUI

struct TasksRowView: View {
    let content: String
    let date: Date
    let isDone: Bool
    let dueDate: Date?
    let task: Task
    @StateObject var viewModel: TasksViewModel
    @State private var showingDatePicker = false
    @State private var selectedDueDate: Date?
    @State private var showingCreateView = false

    init(content: String, date: Date, isDone: Bool, dueDate: Date?, task: Task, viewModel: TasksViewModel) {
        self.content = content
        self.date = date
        self.isDone = isDone
        self.dueDate = dueDate
        self.task = task
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedDueDate = State(initialValue: dueDate)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Checkbox
            Image(systemName: isDone ? "checkmark.square.fill" : "square")
                .foregroundColor(isDone ? .gray : .primary)
                .font(.system(size: 20))
                .onTapGesture {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    viewModel.toggleTaskDone(task: task)
                }
            
            HStack(alignment: .center, spacing: 4) {
                Text(content)
                    .strikethrough(isDone)
                    .foregroundColor(isDone ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .onTapGesture {
                        showingCreateView = true
                    }
                
                Spacer()
                
                if let dueDate = dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "flag")
                            .font(.caption)
                        Text(formattedDueDate(dueDate))
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isDone ? Color(uiColor: .secondarySystemBackground) : (dueDate < Date() ? Color.red.opacity(0.1) : Color(uiColor: .secondarySystemBackground)))
                    .cornerRadius(6)
                    .foregroundColor(isDone ? .secondary : (dueDate < Date() ? .red : .primary))
                    .onTapGesture {
                        selectedDueDate = dueDate
                        showingDatePicker = true
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle()) // Make the entire HStack tappable
        .sheet(isPresented: $showingDatePicker) {
            DueDatePicker(selectedDate: $selectedDueDate, isPresented: $showingDatePicker, onClear: {
                viewModel.updateDueDate(for: task, to: nil)
            })
                .onDisappear {
                    if let newDate = selectedDueDate {
                        viewModel.updateDueDate(for: task, to: newDate)
                    }
                }
        }
        .sheet(isPresented: $showingCreateView) {
            TaskView(viewModel: viewModel, existingTask: task)
        }
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = calendar.isDate(date, equalTo: Date(), toGranularity: .year) ? "MMM d" : "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    Group {
        // Full width preview
        ZStack {
            Color(hex: "ffffff")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Create a mock viewModel for preview
                let viewModel = TasksViewModel()
                
                // Task without due date
                let taskNoDueDate = Task(
                    content: "Simple task without due date",
                    date: Date(),
                    isDone: false
                )
                
                // Task with future due date
                let taskFutureDueDate = Task(
                    content: "Task with future due date",
                    date: Date(),
                    isDone: false,
                    dueDate: Date().addingTimeInterval(86400 * 2)
                )
                
                // Task with past due date
                let taskPastDueDate = Task(
                    content: "Task with past due date",
                    date: Date(),
                    isDone: false,
                    dueDate: Date().addingTimeInterval(-86400)
                )
                
                // Completed task with due date
                let taskCompleted = Task(
                    content: "Completed task with due date",
                    date: Date(),
                    isDone: true,
                    dueDate: Date().addingTimeInterval(86400)
                )
                
                // Display all variations
                TasksRowView(content: taskNoDueDate.content,
                       date: taskNoDueDate.date,
                       isDone: taskNoDueDate.isDone,
                       dueDate: taskNoDueDate.dueDate,
                       task: taskNoDueDate,
                       viewModel: viewModel)
                
                TasksRowView(content: taskFutureDueDate.content,
                       date: taskFutureDueDate.date,
                       isDone: taskFutureDueDate.isDone,
                       dueDate: taskFutureDueDate.dueDate,
                       task: taskFutureDueDate,
                       viewModel: viewModel)
                
                TasksRowView(content: taskPastDueDate.content,
                       date: taskPastDueDate.date,
                       isDone: taskPastDueDate.isDone,
                       dueDate: taskPastDueDate.dueDate,
                       task: taskPastDueDate,
                       viewModel: viewModel)
                
                TasksRowView(content: taskCompleted.content,
                       date: taskCompleted.date,
                       isDone: taskCompleted.isDone,
                       dueDate: taskCompleted.dueDate,
                       task: taskCompleted,
                       viewModel: viewModel)
            }
            .padding()
        }
    }
}
