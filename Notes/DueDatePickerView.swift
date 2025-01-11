import SwiftUI

struct DueDatePickerView: View {
    @Binding var dueDate: Date
    @Binding var hasDueDate: Bool
    @Binding var showingDatePicker: Bool

    var body: some View {
        VStack {
            DatePicker("Select Due Date", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .onChange(of: dueDate) {
                    hasDueDate = true
                    showingDatePicker = false
                }
                .padding()
            
            if hasDueDate {
                HStack {
                    Button("Clear deadline") {
                        hasDueDate = false
                        dueDate = Date()
                        showingDatePicker = false
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
