import SwiftUI

struct TaskView: View {
    let content: String
    let date: Date
    let isDone: Bool
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Text(content)
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.bottom, 40)
                .strikethrough(isDone)
                .opacity(isDone ? 0.6 : 1)
            
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color.primary.opacity(0.09))
                
                HStack(alignment: .center) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .opacity(0.7)
                    
                    Text(formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .opacity(0.7)
                }
                .cornerRadius(20)
                .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .padding(12)
        .frame(maxWidth: 180, minHeight: 180, maxHeight: 180, alignment: .topLeading)
        .background(isDone ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3))
        .cornerRadius(16)
        .shadow(color: Color(red: 0.22, green: 0.2, blue: 0.14).opacity(0.05), radius: 10, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
        )
    }
}

#Preview {
    TaskView(content: "Complete project", date: Date(), isDone: false)
} 