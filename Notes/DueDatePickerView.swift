import SwiftUI

struct DueDatePicker: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented: Bool
    var onClear: (() -> Void)?

    var body: some View {
        VStack {
            DatePicker("Select Due Date", selection: Binding(
                get: { selectedDate ?? Date() },
                set: { selectedDate = $0 }
            ), displayedComponents: .date)
            .datePickerStyle(.graphical)
            .onChange(of: selectedDate) {
                isPresented = false
            }
            .padding()

            if selectedDate != nil {
                Button("Clear deadline") {
                    selectedDate = nil
                    isPresented = false
                    onClear?()
                }
                .foregroundColor(.red)
            }
        }
        .presentationDetents([.medium])
    }
}