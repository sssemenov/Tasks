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
    var dueDate: Date?
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    func addNote(content: String, type: ItemType, dueDate: Date? = nil) {
        let note = Note(content: content, date: Date(), type: type, isDone: false, dueDate: dueDate)
        notes.insert(note, at: 0)
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
    
    func updateNote(note: Note, newContent: String, newDueDate: Date? = nil) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].content = newContent
            notes[index].dueDate = newDueDate
        }
    }
    
    func toggleTaskDone(note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isDone.toggle()
        }
    }
    
    func updateDueDate(for note: Note, to newDueDate: Date?) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].dueDate = newDueDate
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingNoteSheet = false
    @State private var selectedNote: Note?
    
    var notes: [Note] {
        viewModel.notes.filter { $0.type == .note }
    }
    
    var tasks: [Note] {
        viewModel.notes.filter { $0.type == .task }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 4) {
                if notes.isEmpty && tasks.isEmpty {
                    Spacer()
                    Text("Nothing here, yet")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Text("Add tasks to get started.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    //Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if !notes.isEmpty && !tasks.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Notes")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(notes) { note in
                                                NoteView(content: note.content, date: note.date)
                                                    .onTapGesture {
                                                        selectedNote = note
                                                    }
                                            }
                                        }
                                    }
                                }
                            } else if !notes.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(notes) { note in
                                            NoteView(content: note.content, date: note.date)
                                                .onTapGesture {
                                                    selectedNote = note
                                                }
                                        }
                                    }
                                }
                            }
                            
                            if !notes.isEmpty && !tasks.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Tasks")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    LazyVStack(spacing: 0) {
                                        ForEach(tasks) { task in
                                            TaskView(content: task.content,
                                                     date: task.date,
                                                     isDone: task.isDone,
                                                     dueDate: task.dueDate,
                                                     note: task,
                                                     viewModel: viewModel)
                                            Divider()
                                        }
                                    }
                                }
                            } else if !tasks.isEmpty {
                                LazyVStack(spacing: 0) {
                                    ForEach(tasks) { task in
                                        TaskView(content: task.content,
                                                 date: task.date,
                                                 isDone: task.isDone,
                                                 dueDate: task.dueDate,
                                                 note: task,
                                                 viewModel: viewModel)
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Handle search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                Button(action: {
                    selectedNote = nil
                    showingNoteSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                //.padding(.bottom, 16)
            }
            .sheet(isPresented: $showingNoteSheet) {
                CreateView(viewModel: viewModel, existingNote: selectedNote)
            }
            .sheet(item: $selectedNote) { note in
                CreateView(viewModel: viewModel, existingNote: note)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

