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
                
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.primary.opacity(0.6))
            }
            
            Text(content)
                .font(.subheadline)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding()
        .background(Color("Yellow"))
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
}

#Preview {
    Group {
        // Full width preview
        ZStack {
            Color(hex: "FFFEFA")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                NoteView(content: "Short note", date: Date())
                NoteView(content: "Meeting with Client – Ideas for campaign\n• Highlight social media influencers\n• Explore cross-platform integration\n• Fourth line of content", date: Date())
            }
            .padding()
        }
        
        // Half width preview
        ZStack {
            Color(hex: "FFFEFA")
                .ignoresSafeArea()
            
            HStack(spacing: 16) {
                // Left column
                VStack(spacing: 16) {
                    NoteView(content: "Short note", date: Date())
                    NoteView(content: "Medium note with\ntwo lines", date: Date())
                }
                .frame(maxWidth: .infinity)
                
                // Right column (for size reference)
                VStack(spacing: 16) {
                    NoteView(content: "Another note", date: Date())
                    NoteView(content: "One more note\nwith content", date: Date())
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
