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
    @State private var showingNewTaskView = false
    @State private var backgroundOpacity: Double = 0.0
    @State private var showPlusButton = true

    var tasks: [Note] {
        viewModel.notes.filter { $0.type == .task }
    }

    var body: some View {
        NavigationView {
            ZStack {
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
                                    TasksRowView(content: task.content,
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
                .padding(.horizontal, 16)
                .navigationTitle("Journal")

                if showPlusButton {
                    VStack {
                        Spacer()
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingNewTaskView = true
                            showPlusButton = false
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(UIColor.systemGray6))
                                .frame(width: 56, height: 56)
                                .background(Color.primary)
                                .clipShape(Circle())
                        }
                        //.padding(.bottom, 16)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showPlusButton)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .padding(.bottom, 16)
                }

                if showingNewTaskView {
                    Color.black.opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                backgroundOpacity = 0.0
                            }
                            showingNewTaskView = false
                        }

                    NewTaskView(viewModel: viewModel, isPresented: $showingNewTaskView)
                        .onAppear {
                            withAnimation {
                                backgroundOpacity = 0.4
                            }
                        }
                        .onDisappear {
                            withAnimation {
                                backgroundOpacity = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showPlusButton = true
                                }
                            }
                        }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

