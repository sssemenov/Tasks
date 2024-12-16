//
//  StickyNoteView.swift
//  Notes
//
//  Created by Sergei Semenov on 17/11/2024.
//

import SwiftUI

struct CreateView: View {
    enum Tab {
        case note, task
    }
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NotesViewModel
    @State private var content: String
    @State private var selectedTab: Tab
    let isNewNote: Bool
    let existingNote: Note?
    @FocusState private var isContentFocused: Bool
    
    init(viewModel: NotesViewModel, existingNote: Note? = nil) {
        self.viewModel = viewModel
        self.isNewNote = existingNote == nil
        self.existingNote = existingNote
        _content = State(initialValue: existingNote?.content ?? "")
        _selectedTab = State(initialValue: existingNote?.type == .task ? .task : .note)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isNewNote {
                    Picker("Type", selection: $selectedTab) {
                        Text("Note").tag(Tab.note)
                        Text("Task").tag(Tab.task)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
                
                TextField(selectedTab == .note ? "Write something..." : "Add a task...", text: $content, axis: .vertical)
                    .font(.body)
                    .padding()
                    .focused($isContentFocused)
                
                if selectedTab == .task {
                    // Add task-specific UI elements here later
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 44)
                }
                
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                
                Spacer()
            }
            .onTapGesture {
                isContentFocused = true
            }
            .onAppear {
                if isNewNote {
                    isContentFocused = true
                }
            }
            .navigationTitle(isNewNote ? (selectedTab == .note ? "New Note" : "New Task") : "Edit")
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
                            if isNewNote {
                                viewModel.addNote(content: content, type: selectedTab == .note ? .note : .task)
                            } else if let note = existingNote {
                                viewModel.updateNote(note: note, newContent: content)
                            }
                            dismiss()
                        }
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateView(viewModel: NotesViewModel())
}
