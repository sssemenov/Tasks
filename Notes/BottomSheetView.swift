import SwiftUI

struct BottomSheetView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: NotesViewModel
    @State private var content: String = ""
    @State private var dueDate: Date? = nil
    @State private var hasDueDate: Bool = false
    @FocusState private var isContentFocused: Bool

    var body: some View {
        VStack {
            HStack {
                TextField("New Task", text: $content)
                    .focused($isContentFocused)
                    //.padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                
                Button(action: {
                    hasDueDate.toggle()
                }) {
                    Image(systemName: hasDueDate ? "flag.fill" : "flag")
                }
                .padding()
            }
            .padding()

            HStack {
                Button("Save") {
                    if !content.isEmpty {
                        viewModel.addNote(
                            content: content,
                            type: .task,
                            dueDate: hasDueDate ? dueDate : nil
                        )
                        isPresented = false
                    }
                }
                .disabled(content.isEmpty)
                .padding()
                
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
        .onAppear {
            isContentFocused = true
        }
    }
}
