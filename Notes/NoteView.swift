import SwiftUI

struct NoteView: View {
    let content: String
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(systemName: "note.text")
                    .font(.caption2)
                    .foregroundColor(.primary.opacity(0.6))
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.primary.opacity(0.6))
            }
            
            Divider()
            
            Text(content)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
        }
        .padding(16)
        .frame(width: 170, height: 160, alignment: .top)
        .background(Color(hex: "383329"))
        .cornerRadius(20)
        .shadow(color: Color(hex: "383329").opacity(0.01), radius: 10, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
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
    
    private var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            
            let formattedDate = dateFormatter.string(from: date)
            let currentYear = yearFormatter.string(from: Date())
            let noteYear = yearFormatter.string(from: date)
            
            return noteYear == currentYear ? formattedDate : "\(formattedDate) \(noteYear)"
        }
    }
}

#Preview {
    Group {
        // Full width preview
        ZStack {
            Color(hex: "FFFEFA")
                .ignoresSafeArea()
            
            HStack(spacing: 16) {
                NoteView(content: "Short note", date: Date())
                NoteView(content: "Meeting with Client – Ideas for campaign\n• Highlight social media influencers\n• Explore cross-platform integration\n• Fourth line of content", date: Date())
            }
            .padding()
        }
        
        
    }
}
