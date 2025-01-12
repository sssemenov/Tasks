//
//  NewEntryView.swift
//  Notes
//
//  Created by Sergei Semenov on 12/01/2025.
//

import SwiftUI

struct NewEntryView: View {
    @State private var content: String = ""
    @State private var showingDatePicker = false
    @State private var showingReminderPicker = false
    @FocusState private var isContentFocused: Bool
    @State private var viewOpacity: Double = 0.0

    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 56) {
                TextField("New entry", text: $content)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .focused($isContentFocused)
                
                HStack {
                    Button(action: {
                        showingDatePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "flag")
                            Text("Deadline")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showingReminderPicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "bell")
                            Text("Reminder")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 24)
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
        .sheet(isPresented: $showingDatePicker) {
            // Placeholder for DatePicker
            Text("Date Picker")
        }
        .sheet(isPresented: $showingReminderPicker) {
            // Placeholder for Reminder Picker
            Text("Reminder Picker")
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
    NewEntryView()
}
