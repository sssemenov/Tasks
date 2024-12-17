import SwiftUI

struct PreviewScreen: View {
    let mockNotes = [
        Note(content: "Buy groceries for the week:\n• Milk\n• Eggs\n• Bread\n• Vegetables", date: Date().addingTimeInterval(-86400 * 2), type: .task, isDone: true),
        Note(content: "Remember to call mom and wish her happy birthday! 🎂", date: Date().addingTimeInterval(-86400), type: .note),
        Note(content: "Project meeting notes:\n- Review designs\n- Discuss timeline\n- Set up follow-up", date: Date(), type: .note),
        Note(content: "Fix bathroom", date: Date().addingTimeInterval(-86400 * 3), type: .task, isDone: false),
        Note(content: "The new coffee shop on 5th Avenue has amazing pastries! Must try their croissants next time ☕️", date: Date().addingTimeInterval(-86400 * 4), type: .note),
        Note(content: "Finish reading 'Atomic Habits'", date: Date().addingTimeInterval(-86400 * 5), type: .task, isDone: false),
        Note(content: "Ideas for Sarah's surprise party:\n• Book restaurant\n• Order cake\n• Send invites", date: Date().addingTimeInterval(-86400 * 6), type: .task, isDone: false),
        Note(content: "🎵 New playlist recommendations:\n- Midnight Blues\n- Summer Vibes\n- Coding Focus", date: Date().addingTimeInterval(-86400 * 7), type: .note)
    ]
    
    var columnItems: (left: [Note], right: [Note]) {
        var leftColumn: [Note] = []
        var rightColumn: [Note] = []
        
        for (index, note) in mockNotes.enumerated() {
            if index % 2 == 0 {
                leftColumn.append(note)
            } else {
                rightColumn.append(note)
            }
        }
        
        return (leftColumn, rightColumn)
    }
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 16) {
                // Left Column
                VStack(spacing: 16) {
                    ForEach(columnItems.left) { note in
                        if note.type == .note {
                            NoteView(content: note.content, date: note.date)
                        } else {
                            TaskView(content: note.content, date: note.date, isDone: note.isDone)
                        }
                    }
                }
                
                // Right Column
                VStack(spacing: 16) {
                    ForEach(columnItems.right) { note in
                        if note.type == .note {
                            NoteView(content: note.content, date: note.date)
                        } else {
                            TaskView(content: note.content, date: note.date, isDone: note.isDone)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color("Background"))
    }
}

#Preview {
    PreviewScreen()
}//
//  MockData.swift
//  Notes
//
//  Created by Sergei Semenov on 17/12/2024.
//

