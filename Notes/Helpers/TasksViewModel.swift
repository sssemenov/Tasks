import SwiftUI

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
