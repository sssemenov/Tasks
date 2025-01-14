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

struct ContentView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showNewTaskView = false
    @State private var backgroundOpacity: Double = 0.0
    @State private var showPlusButton = true

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 4) {
                    if viewModel.tasks.isEmpty {
                        Empty1View()
                    } else {
                        ScrollView(showsIndicators: false) {
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
                                withAnimation {
                                    showNewTaskView = true
                                    showPlusButton = false
                                }
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
                    
                }

                if showNewTaskView {
                    Color.black.opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                backgroundOpacity = 0.0
                            }
                            showNewTaskView = false
                        }

                    NewTaskView(viewModel: viewModel, isPresented: $showNewTaskView)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                backgroundOpacity = 0.4
                            }
                        }
                        .onDisappear {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                backgroundOpacity = 0.0
                                showPlusButton = true
                            }
                        }
                }
            }
            .background(Color("Background"))
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

