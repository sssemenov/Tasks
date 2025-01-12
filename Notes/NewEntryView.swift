//
//  NewEntryView.swift
//  Notes
//
//  Created by Sergei Semenov on 12/01/2025.
//

import SwiftUI

struct NewEntryView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var content: String = ""
    @State private var showingDatePicker = false
    @State private var showingReminderPicker = false
    @FocusState private var isContentFocused: Bool
    @State private var viewOpacity: Double = 0.0
    @Binding var isPresented: Bool
    @State private var dueDate: Date? = nil
    @State private var hasDueDate: Bool = false

    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(spacing: 24) {
                
                Rectangle()
                    .fill(Color(UIColor.systemFill))
                    .frame(width: 40, height: 4)
                    .cornerRadius(2)

                VStack(alignment: .leading, spacing: 56) {
                    TextField("New entry", text: $content)
                        .font(.title2)
                        .padding(.horizontal, 16)
                        .focused($isContentFocused)
                    HStack {
                        Button(action: {
                            showingDatePicker.toggle()
                        }) {
                            HStack {
                                Image(systemName: hasDueDate ? "flag.fill" : "flag")
                                Text(hasDueDate ? "\(formattedDueDate(dueDate))" : "Deadline")
                                
                                if hasDueDate {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            clearDueDate()
                                        }
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if !content.isEmpty {
                                isContentFocused = false
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.addNote(
                                        content: content,
                                        type: .task,
                                        dueDate: hasDueDate ? dueDate : nil
                                    )
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.up")
                                    .foregroundColor(content.isEmpty ? Color(UIColor.tertiaryLabel) : Color(UIColor.systemGray6))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(content.isEmpty ? Color(UIColor.secondarySystemBackground).opacity(0.8) : Color.primary)
                            .cornerRadius(999)
                        }
                        .disabled(content.isEmpty)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))
            .onAppear {
                withAnimation(.easeIn(duration: 0.1)) {
                    viewOpacity = 1.0
                }
                isContentFocused = true
            }
        }
        .opacity(viewOpacity)
        //.background(Color(UIColor.systemGray5)) //dim overaly for preview
        .sheet(isPresented: $showingDatePicker) {
            DueDatePicker(selectedDate: $dueDate, isPresented: $showingDatePicker, onClear: clearDueDate)
                .onDisappear {
                    hasDueDate = dueDate != nil
                }
        }
        .sheet(isPresented: $showingReminderPicker) {
            // Placeholder for Reminder Picker
            Text("Reminder Picker")
        }
    }

    private func clearDueDate() {
        dueDate = nil
        hasDueDate = false
    }

    private func formattedDueDate(_ date: Date?) -> String {
        guard let date = date else { return "No Date" }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = calendar.isDate(date, equalTo: Date(), toGranularity: .year) ? "MMM d" : "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    NewEntryView(viewModel: NotesViewModel(), isPresented: .constant(true))
}
