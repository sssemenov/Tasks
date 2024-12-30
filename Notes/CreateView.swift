//
//  StickyNoteView.swift
//  Notes
//
//  Created by Sergei Semenov on 17/11/2024.
//

import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NotesViewModel
    @State private var content: String
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
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
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Write something...", text: $content, axis: .vertical)
                    .font(.body)
                    .padding()
                    .focused($isContentFocused)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        showingDatePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(hasDueDate ? "Due Date: \(formattedDueDate(dueDate))" : "Add due date")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if hasDueDate {
                        Button(action: {
                            hasDueDate = false
                            dueDate = Date()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
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
            .navigationTitle(existingNote == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                VStack {
                    DatePicker("Select Due Date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                    
                    HStack {
                        Button("Done") {
                            hasDueDate = true
                            showingDatePicker = false
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("Remove Due Date") {
                            hasDueDate = false
                            showingDatePicker = false
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    CreateView(viewModel: NotesViewModel())
}
