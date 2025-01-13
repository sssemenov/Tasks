//
//  StickyNoteView.swift
//  Notes
//
//  Created by Sergei Semenov on 17/11/2024.
//

import SwiftUI
import UserNotifications

struct TaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TasksViewModel
    @State private var content: String
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    let existingTask: Task?
    @FocusState private var isContentFocused: Bool
    @State private var showingDatePicker = false
    
    init(viewModel: TasksViewModel, existingTask: Task? = nil) {
        self.viewModel = viewModel
        self.existingTask = existingTask
        _content = State(initialValue: existingTask?.content ?? "")
        if let existingDueDate = existingTask?.dueDate {
            _dueDate = State(initialValue: existingDueDate)
            _hasDueDate = State(initialValue: true)
        } else {
            _dueDate = State(initialValue: nil)
            _hasDueDate = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    TextField("New Task", text: $content, axis: .vertical)
                        .font(.title2)
                        .padding(.horizontal, 16)
                        .focused($isContentFocused)
                    
                    Spacer()
                }
                .onTapGesture {
                    isContentFocused = true
                }
                .onAppear {
                    if existingTask == nil {
                        isContentFocused = true
                    }
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showingDatePicker.toggle()
                        }) {
                            HStack {
                                Image(systemName: hasDueDate ? "flag.fill" : "flag")
                                Text(hasDueDate ? "\(formattedDueDate(dueDate))" : "Deadline")
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            scheduleNotification()
                        }) {
                            // Notification button code
                        }
                        
                        if hasDueDate {
                            Button(action: {
                                clearDueDate()
                            }) {
                                Image(systemName: "multiply")
                                    .foregroundColor(.primary)
                            }
                            .padding(20)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .padding(.leading, 8)
                        }
                        
                        Spacer()
                        
                        if existingTask != nil {
                            Button(action: {
                                withAnimation {
                                    dismiss()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if let task = existingTask {
                                        viewModel.deleteTaskById(task.id)
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(16)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(999)
                            .padding(.leading, 8)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 4)
                            .cornerRadius(2)
                        Spacer()
                    }
                }
                
                if existingTask == nil || isContentFocused {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            if !content.isEmpty {
                                if existingTask == nil {
                                    viewModel.addTask(
                                        content: content,
                                        dueDate: hasDueDate ? dueDate : nil
                                    )
                                    dismiss()
                                } else if let task = existingTask {
                                    viewModel.updateTask(
                                        task: task,
                                        newContent: content,
                                        newDueDate: hasDueDate ? dueDate : nil
                                    )
                                }
                                isContentFocused = false
                            }
                        }
                        .disabled(content.isEmpty)
                        .foregroundColor(content.isEmpty ? Color(UIColor.systemBackground) : .primary)
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DueDatePicker(selectedDate: $dueDate, isPresented: $showingDatePicker, onClear: clearDueDate)
                    .onDisappear {
                        hasDueDate = dueDate != nil
                        if let task = existingTask {
                            viewModel.updateDueDate(for: task, to: dueDate)
                        }
                    }
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = self.content
        content.sound = .default
        
        if let dueDate = dueDate {
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func formattedDueDate(_ date: Date?) -> String {
        guard let date = date else { return "No Date" }
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
    
    private func clearDueDate() {
        dueDate = nil
        hasDueDate = false
        if let task = existingTask {
            viewModel.updateDueDate(for: task, to: nil)
        }
    }
}

#Preview {
    TaskView(viewModel: TasksViewModel())
}
