import SwiftUI

enum ItemType {
    case note
    case task
}

struct Note: Identifiable {
    let id = UUID()
    var content: String
    var date: Date
    var type: ItemType
    var isDone: Bool = false
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    func addNote(content: String, type: ItemType) {
        let note = Note(content: content, date: Date(), type: type)
        notes.insert(note, at: 0)
    }
    
    func deleteNote(at offsets: IndexSet) { 
        notes.remove(atOffsets: offsets)
    }
    
    func updateNote(note: Note, newContent: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].content = newContent
        }
    }
    
    func toggleTaskDone(note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isDone.toggle()
        }
    }
}

struct ContentView: View {
    @State private var AnimatedIcon = false
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingNoteSheet = false
    @State private var selectedNote: Note?
    
    // Compute two arrays for left and right columns
    var columnItems: (left: [Note], right: [Note]) {
        var leftColumn: [Note] = []
        var rightColumn: [Note] = []
        
        for (index, note) in viewModel.notes.enumerated() {
            if index % 2 == 0 {
                leftColumn.append(note)
            } else {
                rightColumn.append(note)
            }
        }
        
        return (leftColumn, rightColumn)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    if viewModel.notes.isEmpty {
                        VStack {
                            VStack(spacing: 4) {
                                Text("Nothing here yet")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Tap + to create your first note or task")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("Background"))
                        
                    } else {
                        ScrollView {
                            HStack(alignment: .top, spacing: 16) {
                                // Left Column
                                VStack(spacing: 16) {
                                    ForEach(columnItems.left) { note in
                                        noteOrTaskView(for: note)
                                    }
                                }
                                
                                // Right Column
                                VStack(spacing: 16) {
                                    ForEach(columnItems.right) { note in
                                        noteOrTaskView(for: note)
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 80) // Add padding for the floating button
                        }
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    Button(action: {
                        selectedNote = nil
                        showingNoteSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            //.shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Handle profile button action
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingNoteSheet) {
                CreateView(viewModel: viewModel, existingNote: selectedNote)
            }
            .sheet(item: $selectedNote) { note in
                CreateView(viewModel: viewModel, existingNote: note)
            }
            .background(Color("Background"))
        }
    }
    
    @ViewBuilder
    private func noteOrTaskView(for note: Note) -> some View {
        Group {
            if note.type == .note {
                NoteView(content: note.content, date: note.date)
            } else {
                TaskView(content: note.content, date: note.date, isDone: note.isDone)
                    .onTapGesture {
                        if note.type == .task {
                            viewModel.toggleTaskDone(note: note)
                        } else {
                            selectedNote = note
                        }
                    }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                    viewModel.deleteNote(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ContentView()
    
}
