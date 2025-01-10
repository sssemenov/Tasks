//
//  StickyNoteView.swift
//  Notes
//
//  Created by Sergei Semenov on 17/11/2024.
//

import SwiftUI
import UserNotifications

struct CreateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NotesViewModel
    @State private var content: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    let existingNote: Note?
    @FocusState private var isContentFocused: Bool
    @State private var showingDatePicker = false
    
    init(viewModel: NotesViewModel, existingNote: Note? = nil) {
        self.viewModel = viewModel
        self.existingNote = existingNote
        _content = State(initialValue: existingNote?.content ?? "")
        if let existingDueDate = existingNote?.dueDate {
            _dueDate = State(initialValue: existingDueDate)
            _hasDueDate = State(initialValue: true)
        } else {
            _dueDate = State(initialValue: Date())
            _hasDueDate = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("New Task", text: $content, axis: .vertical)
                    .font(.body)
                    .padding()
                    .focused($isContentFocused)
                
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
//                        HStack {
//                            Image(systemName: "bell")
//                            Text("Reminder")
//                        }
//                        .padding()
//                        .background(Color(UIColor.secondarySystemBackground))
//                        .foregroundColor(.primary)
//                        .cornerRadius(8)
                    }
                    
                    if hasDueDate {
                        Button(action: {
                            hasDueDate = false
                            dueDate = Date()
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
                }
                .padding()
            }
            .onTapGesture {
                isContentFocused = true
            }
            .onAppear {
                if existingNote == nil {
                    isContentFocused = true
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !content.isEmpty {
                            if existingNote == nil {
                                viewModel.addNote(
                                    content: content,
                                    type: .task,
                                    dueDate: hasDueDate ? dueDate : nil
                                )
                            } else if let note = existingNote {
                                viewModel.updateNote(
                                    note: note,
                                    newContent: content,
                                    newDueDate: hasDueDate ? dueDate : nil
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(content.isEmpty)
                    .foregroundColor(content.isEmpty ? Color(UIColor.systemGray5) : .primary)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                VStack {
                    DatePicker("Select Due Date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .onChange(of: dueDate) { newDate in
                            hasDueDate = true
                            showingDatePicker = false
                        }
                        .padding()
                    
                    if hasDueDate {
                        HStack {
                            Button("Clear deadline") {
                                hasDueDate = false
                                dueDate = Date()
                                showingDatePicker = false
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = self.content
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
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
    CreateView(viewModel: NotesViewModel())
}
