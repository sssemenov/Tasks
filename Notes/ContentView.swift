import SwiftUI

struct Task: Identifiable, Codable {
    let id: UUID
    var content: String
    var date: Date
    var isDone: Bool = false
    var dueDate: Date?

    enum CodingKeys: String, CodingKey {
        case id, content, date, isDone, dueDate
    }

    init(id: UUID = UUID(), content: String, date: Date, isDone: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.content = content
        self.date = date
        self.isDone = isDone
        self.dueDate = dueDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        isDone = try container.decode(Bool.self, forKey: .isDone)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
    }
}

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    
    private let tasksKey = "tasksKey"
    
    init() {
        loadTasks()
    }
    
    func addTask(content: String, dueDate: Date? = nil) {
        let task = Task(content: content, date: Date(), isDone: false, dueDate: dueDate)
        tasks.insert(task, at: 0)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func updateTask(task: Task, newContent: String, newDueDate: Date? = nil) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].content = newContent
            tasks[index].dueDate = newDueDate
        }
    }
    
    func toggleTaskDone(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
        }
    }
    
    func updateDueDate(for task: Task, to newDueDate: Date?) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].dueDate = newDueDate
        }
    }
    
    func deleteTaskById(_ id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let savedTasks = UserDefaults.standard.object(forKey: tasksKey) as? Data {
            if let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
                tasks = decodedTasks
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showingNewTaskView = false
    @State private var backgroundOpacity: Double = 0.0
    @State private var showPlusButton = true

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 4) {
                    if viewModel.tasks.isEmpty {
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
                                ForEach(viewModel.tasks.sorted(by: { 
                                    ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) 
                                })) { task in
                                    TasksRowView(content: task.content,
                                                 date: task.date,
                                                 isDone: task.isDone,
                                                 dueDate: task.dueDate,
                                                 task: task,
                                                 viewModel: viewModel)
                                    Divider()
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .navigationTitle("Tasks")

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

