//
//  NewEntryView.swift
//  Notes
//
//  Created by Sergei Semenov on 12/01/2025.
//

import SwiftUI

struct NewTaskView: View {
    @ObservedObject var viewModel: TasksViewModel
    @State private var content: String = ""
    @State private var showingDatePicker = false
    @State private var showingReminderPicker = false
    @FocusState private var isContentFocused: Bool
    @State private var viewOpacity: Double = 0.0
    @Binding var isPresented: Bool
    @State private var dueDate: Date? = nil
    @State private var hasDueDate: Bool = false
    @State private var buttonVisible: Bool = false

    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                VStack(alignment: .leading, spacing: 56) {
                    TextField("Task Name", text: $content, axis: .vertical)
                        .font(.title2)
                        .padding(.horizontal, 16)
                        .focused($isContentFocused)
                        .onChange(of: content) { newValue in
                            withAnimation {
                                buttonVisible = !newValue.isEmpty
                            }
                        }
                    HStack {
                        Button(action: {
                            showingDatePicker.toggle()
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.callout)
                                    .foregroundColor(hasDueDate ? .primary : Color(UIColor.secondaryLabel))

                                Text(hasDueDate ? "\(formattedDueDate(dueDate))" : "Deadline")
                                    .font(.callout)
                                    .foregroundColor(hasDueDate ? .primary : Color(UIColor.secondaryLabel))

                                if hasDueDate {
                                    Image(systemName: "multiply.circle.fill")
                                        .font(.subheadline)
                                        
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                        .onTapGesture {
                                            clearDueDate()
                                        }
                                }
                            }
                            .padding(12)
                            //.background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        if !content.isEmpty {
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                isContentFocused = false
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.addTask(
                                        content: content,
                                        dueDate: hasDueDate ? dueDate : nil
                                    )
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(UIColor.systemGray6))
                                }
                                .padding(12)
                                .background(Color.primary)
                                .cornerRadius(999)
                            }
                            .scaleEffect(buttonVisible ? 1.0 : 0.0)
                            .animation(.interpolatingSpring(stiffness: 400, damping: 20), value: buttonVisible)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
            .background(Color("Background-elevated"))
            .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 8))
            .shadow(color: Color.black.opacity(0.1), radius: 32, x: 0, y: 5)
            .onAppear {
                isContentFocused = true
                withAnimation(.easeIn(duration: 0.15)) {
                    viewOpacity = 1.0
                }
            }
            .onDisappear {
                isContentFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        viewOpacity = 0.0
                    }
                }
            }
        }
        .opacity(viewOpacity)
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
    NewTaskView(viewModel: TasksViewModel(), isPresented: .constant(true))
}
