import SwiftUI

enum ItemType: String, Codable {
    case note
    case task
}

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    var date: Date
    var type: ItemType
    var isDone: Bool = false
    var dueDate: Date?

    enum CodingKeys: String, CodingKey {
        case id, content, date, type, isDone, dueDate
    }

    init(id: UUID = UUID(), content: String, date: Date, type: ItemType, isDone: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.content = content
        self.date = date
        self.type = type
        self.isDone = isDone
        self.dueDate = dueDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        type = try container.decode(ItemType.self, forKey: .type)
        isDone = try container.decode(Bool.self, forKey: .isDone)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
    }
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    
    private let notesKey = "notesKey"
    
    init() {
        loadNotes()
    }
    
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
    
    func deleteNoteById(_ id: UUID) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes.remove(at: index)
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.object(forKey: notesKey) as? Data {
            if let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes) {
                notes = decodedNotes
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingNoteSheet = false
    @State private var selectedNote: Note?
    
    var tasks: [Note] {
        viewModel.notes.filter { $0.type == .task }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 4) {
                if tasks.isEmpty {
                    Spacer()
                    Text("Nothing here, yet")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Text("Add tasks to get started.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(tasks) { task in
                                TaskView(content: task.content,
                                         date: task.date,
                                         isDone: task.isDone,
                                         dueDate: task.dueDate,
                                         note: task,
                                         viewModel: viewModel)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        if let index = viewModel.notes.firstIndex(where: { $0.id == task.id }) {
                                            viewModel.notes.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                Divider()
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
                        //Image(systemName: "magnifyingglass")
                            //.foregroundColor(.primary)
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
                        .foregroundColor(Color(UIColor.systemGray6))
                        .frame(width: 56, height: 56)
                        .background(Color.primary)
                        .clipShape(Circle())
                }
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

