import SwiftUI

struct TaskView: View {
    let content: String
    let date: Date
    let isDone: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.primary.opacity(0.6))
                
                Spacer()
                
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isDone ? .green : .gray)
            }
            
            HStack(alignment: .top) {
                
                
                Text(content)
                    .font(.subheadline)
                    .strikethrough(isDone)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
        }
        .padding()
        .background(isDone ? Color("Grey") : Color("Blue"))
        .cornerRadius(20)
        .shadow(color: Color(hex: "383329").opacity(0.01), radius: 10, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors:[
                            Color(hex: "000000").opacity(0.1),
                            Color(hex: "FFFFFF").opacity(0.1)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    ),
                    lineWidth: 1
            )
        )
    }
}

#Preview {
    Group {
        // Full width preview
        ZStack {
            Color(hex: "FFFEFA")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                TaskView(content: "Short task", date: Date(), isDone: false)
                TaskView(content: "Long task with multiple lines\n• First item to do\n• Second item to do\n• Third item to do", date: Date(), isDone: true)
            }
            .padding()
        }
        
        // Half width preview
        ZStack {
            Color(hex: "FFFEFA")
                .ignoresSafeArea()
            
            HStack(alignment: .top, spacing: 16) {
                // Left column
                VStack(spacing: 16) {
                    TaskView(content: "Short task new way to learn new stuff", date: Date(), isDone: false)
                    TaskView(content: "Medium task\n• First item", date: Date(), isDone: true)
                }
                .frame(maxWidth: .infinity)
                
                // Right column (for size reference)
                VStack(spacing: 16) {
                    TaskView(content: "Another task", date: Date(), isDone: true)
                    TaskView(content: "Finalize presentation for client pitch.", date: Date(), isDone: false)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
